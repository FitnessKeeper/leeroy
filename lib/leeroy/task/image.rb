require 'leeroy'
require 'leeroy/task'
require 'leeroy/helpers/aws'
require 'leeroy/helpers/env'

module Leeroy
  module Task
    class Image < Leeroy::Task::Base
      include Leeroy::Helpers::AWS

      def perform(args = self.args, options = self.options, global_options = self.global_options)
        begin
          super(args, options, global_options)

          # create image
          image_params = _genImageParams

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

          image_params.instance_id = state.instanceid

          # were we given an app_name?

        rescue StandardError => e
          raise e
        end
      end

    end
  end
end
