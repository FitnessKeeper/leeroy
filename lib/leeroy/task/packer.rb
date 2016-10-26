require 'leeroy'
require 'leeroy/task'
require 'leeroy/helpers/aws'
require 'leeroy/helpers/inventory'
require 'packer'
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
      #include Leeroy::Helpers::Polling
      #include Leeroy::Helpers::Template

      def perform(args = self.args, options = self.options, global_options = self.global_options)
        begin
          super(args, options, global_options)

          phase = Leeroy::Types::Phase.resolve(self.state.fetch('phase'), options[:phase])
          logger.debug "phase: #{phase}"
          self.state.phase = phase


          begin
            # we should probably check that this isn't empty
            template = options[:template]
            logger.debug "Loading Packer Template from :'#{template}'"

          rescue SystemCallError => e
            logger.debug e.message
            logger.debug "reading template from provided string"
          end


         # client.validate('/Users/alaric/git/packer-rk-apps/rk-bastion/main.json').valid?


          dump_state

          logger.debug "done performing for #{self.class}"

        rescue StandardError => e
          raise e
        end
      end

      def initialize(*args, &block)
        super

      end
      private

    end
  end
end
