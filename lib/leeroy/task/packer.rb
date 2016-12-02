require 'leeroy'
require 'leeroy/task'
require 'leeroy/helpers/aws'
require 'leeroy/helpers/packer'
require 'leeroy/types/packer'

# input
# pass in path to packer template - ex rk-bastion/main.json
# AWS_DEFAULT_REGION=us-east-1
# LEEROY_AWS_LINUX_AMI=ami-b73b63a0
# LEEROY_APP_NAME=rk-bastion
# LEEROY_PACKER_TEMPLATE_PREFIX=/data/packer-rk-apps
# Output region and AMI

module Leeroy
  module Task
    class Packer < Leeroy::Task::Base
      include Leeroy::Helpers::AWS
      include Leeroy::Helpers::Packer

      def perform(args = self.args, options = self.options, global_options = self.global_options)
        begin
          super(args, options, global_options)

          phase = Leeroy::Types::Phase.resolve(self.state.fetch('phase'), options[:phase])
          logger.debug "phase: #{phase}"
          # update phase in state
          self.state.phase = phase

          packer_params = _getPackerParams
          packer_vars = Leeroy::Types::Packer.new(packer_params)

          # Sending app_name to state
          self.state.app_name = packer_vars.app_name

          # cwd is the fille filename where the packer template lives
          cwd = File.join(packer_vars.packer_template_prefix, self.state.app_name)

          validation = validatePacker(cwd, { :vars => packer_vars })

          build = buildPacker(cwd,{ :vars => packer_vars } )
          build.artifacts.each do | item |
            self.state.message = item.string
            artifact = item.id.split(':')
            self.state.imageid = artifact[1]
          end

          logger.debug "#{build.stdout}"
          logger.debug "Packer Artifact Created : #{state.imageid}"

          dump_state

          logger.debug "done performing for #{self.class}"

        rescue StandardError => e
          logger.debug e.message
          raise e
        end
      end
      private
      def _getPackerParams(state = self.state, env = self.env, options = self.options)
        begin
          logger.debug "generating Packer params to create an AMI"
          packer_params = Leeroy::Types::Mash.new

          if self.state.imageid?
            imageid = self.state.imageid
          elsif options[:imageid].nil?
            imageid = checkEnv('LEEROY_AWS_LINUX_AMI')
          else
            imageid = options[:imageid]
          end
          packer_params.aws_linux_ami = imageid

          if self.state.app_name?
            app_name = self.state.app_name
          elsif options[:name].nil?
            app_name = checkEnv('LEEROY_APP_NAME')
          else
            app_name = options[:name]
          end
          packer_params.app_name = app_name

          if self.state.aws_region?
            aws_region = self.state.aws_region
          else
            aws_region = ENV['AWS_DEFAULT_REGION'] || ENV['AWS_REGION']
          end
          packer_params.aws_region = aws_region

          # LEEROY_PACKER_TEMPLATE_PREFIX
          if self.state.packer_template_prefix?
            packer_template_prefix = self.state.packer_template_prefix
          elsif options[:packer_template_prefix].nil?
            packer_template_prefix = checkEnv('LEEROY_PACKER_TEMPLATE_PREFIX')
          else
            packer_template_prefix = options[:packer_template_prefix]
          end
          packer_params.packer_template_prefix = packer_template_prefix

          packer_params
        rescue StandardError => e
          raise e
        end
      end
    end
  end
end
