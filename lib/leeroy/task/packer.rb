require 'leeroy'
require 'leeroy/task'
require 'leeroy/helpers/aws'
require 'leeroy/helpers/inventory'
require 'leeroy/helpers/packer'
#require 'leeroy/helpers/polling'
#require 'leeroy/helpers/template'

# input
# pass in path to packer template - ex rk-bastion/main.json
# LEEROY_APP_NAME=rk-bastion
# LEEROY_AWS_LINUX_AMI=ami-c481fad3
# LEEROY_BUILD_INSTANCE_TYPE=m3.medium
# AWS_REGION=us-east-1

# Output region and AMI


module Leeroy
  module Task
    class Packer < Leeroy::Task::Base
      include Leeroy::Helpers::AWS
      include Leeroy::Helpers::Inventory
      include Leeroy::Helpers::Packer

      #def initialize(*args, &block)
      #  super
      #  @client = ::Packer::Client.new
      #end

      def perform(args = self.args, options = self.options, global_options = self.global_options)
        begin
          super(args, options, global_options)

          phase = Leeroy::Types::Phase.resolve(self.state.fetch('phase'), options[:phase])
          logger.debug "phase: #{phase}"
          self.state.phase = phase

          packer_vars = {
            :app_name      => checkEnv('LEEROY_APP_NAME'),
            :aws_linux_ami => checkEnv('LEEROY_AWS_LINUX_AMI'),
            :aws_region    => ENV['AWS_REGION']
          }
          cwd = File.join(checkEnv('LEEROY_PACKER_TEMPLATE_PREFIX'), checkEnv('LEEROY_APP_NAME'))

          begin
            # we should probably check that this isn't empty
            #packer.perform({},{ :phase => 'gold_master', :template => '/Users/alaric/git/packer-rk-apps/rk-bastion/main.json' })
            # LEEROY_APP_NAME
            # We will build the path to the template with LEEROY_PACKER_TEMPLATE_PREFIX LEEROY_APP_NAME and assume the template uses main.json
            # Also, lets *pass in* the --phase=arg into the packer template itself, and let puppet, or whatever handle

            # { :vars => { :aws_linux_ami=>'ami-c481fad3', :app_name=>'rk-bastion', :aws_region =>'us-east-1'}
            # LEEROY_APP_NAME LEEROY_AWS_LINUX_AMI AWS_REGION

            validation = validatePacker(cwd, { :vars => packer_vars })

            build = buildPacker(cwd,{ :vars => packer_vars } )
            build.artifacts.each do | item |
              state.message = item.string
              artifact = item.id.split(':')
              state.imageid = artifact[1]
            end

            logger.debug "Packer Artifact : #{self.class}"

          rescue StandardError => e
            logger.debug e.message
            raise e
          end

         # client.validate('/Users/alaric/git/packer-rk-apps/rk-bastion/main.json').valid?

          dump_state

          logger.debug "done performing for #{self.class}"

        rescue StandardError => e
          raise e
        end
      end

      private
    end
  end
end
