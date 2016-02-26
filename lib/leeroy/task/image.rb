require 'leeroy'
require 'leeroy/task'
require 'leeroy/helpers/aws'
require 'leeroy/helpers/env'
require 'leeroy/types/image'

module Leeroy
  module Task
    class Image < Leeroy::Task::Base
      include Leeroy::Helpers::AWS

      def perform(args = self.args, options = self.options, global_options = self.global_options)
        begin
          super(args, options, global_options)

          phase = self.state.fetch('phase', options[:phase])

          # create image
          image_params = _genImageParams

          exit

          self.state.imageid = imageid

          dump_state

          logger.debug "done performing for #{self.class}"

        rescue StandardError => e
          raise e
        end
      end

      private

      def _genImageParams(state = self.state, env = self.env, ec2 = self.ec2, options = self.options)
        begin
          logger.debug "generating params for creating an EC2 image"

          image_params = Leeroy::Types::Mash.new

          # get instance_id from state or options
          instance_id = state.instanceid? ? state.instanceid : options[:instance]
          raise "Unable to determine instance ID, exiting." if instance_id.nil?
          logger.debug "instance_id: #{instance_id}"
          image_params.instance_id = instance_id

          # were we given an app_name?
          app_name = state.app_name? ? state.app_name : checkEnv('LEEROY_APP_NAME')
          logger.debug "app_name: #{app_name}"

        rescue StandardError => e
          raise e
        end
      end

    end
  end
end
