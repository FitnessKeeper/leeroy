require 'leeroy'
require 'leeroy/task'
require 'leeroy/helpers/aws'
require 'leeroy/helpers/inventory'
require 'leeroy/helpers/packer'
require 'leeroy/types/packer'

# input
# pass in path to packer template - ex rk-bastion/main.json
# LEEROY_APP_NAME=rk-bastion
# LEEROY_AWS_LINUX_AMI=ami-c481fad3
# AWS_REGION=us-east-1

# Output region and AMI

module Leeroy
  module Task
    class Packer < Leeroy::Task::Base
      include Leeroy::Helpers::AWS
      include Leeroy::Helpers::Inventory
      include Leeroy::Helpers::Packer

      def perform(args = self.args, options = self.options, global_options = self.global_options)
        begin
          super(args, options, global_options)

          phase = Leeroy::Types::Phase.resolve(self.state.fetch('phase'), options[:phase])
          logger.debug "phase: #{phase}"
          self.state.phase = phase

          packer_vars = Leeroy::Types::Packer.new
          packer_params = _getPackerParams
          packer_vars = Leeroy::Types::Packer.new(packer_params)


          cwd = File.join(checkEnv('LEEROY_PACKER_TEMPLATE_PREFIX'), checkEnv('LEEROY_APP_NAME'))

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
      #def _genImageParams(phase, state = self.state, env = self.env, options = self.options)
        begin
          logger.debug "generating Packer params to create an AMI"
          packer_params = Leeroy::Types::Mash.new
          #packer_params.phase = phase


          if self.state.imageid?
            imageid = self.state.imageid
          elsif options[:imageid].nil?
            imageid = checkEnv('LEEROY_AWS_LINUX_AMI')
          else
            imageid = options[:imageid]
          end
          packer_params.imageid = imageid

          if self.state.app_name?
            app_name = self.state.app_name
          elsif options[:name].nil?
            app_name = checkEnv('LEEROY_APP_NAME')
          else
            app_name = options[:name]
          end

#          packer_vars = {
#            :app_name      => checkEnv('LEEROY_APP_NAME'),
#            :aws_linux_ami => imageid,
#            :aws_region    => ENV['AWS_REGION']
#          }


          packer_params
###
#begin
#  logger.debug "generating params for creating an EC2 image"

#  image_params = Leeroy::Types::Mash.new

  #image_params.phase = phase

  # get instance_id from state or options


  ##instance_id = state.instanceid? ? state.instanceid : options[:instance]
  ##raise "Unable to determine instance ID, exiting." if instance_id.nil?
  ##logger.debug "instance_id: #{instance_id}"
  ##image_params.instance_id = instance_id

  # generate image name based on state data
  ##image_params.name = genImageName(phase, state)

  ##image_params
###



        rescue StandardError => e
          raise e
        end
      end
    end
  end
end
