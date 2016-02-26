require 'leeroy'
require 'leeroy/task'
require 'leeroy/helpers/aws'
require 'leeroy/helpers/env'
require 'leeroy/types/image'
require 'leeroy/types/phase'

module Leeroy
  module Task
    class Image < Leeroy::Task::Base
      include Leeroy::Helpers::AWS

      def perform(args = self.args, options = self.options, global_options = self.global_options)
        begin
          super(args, options, global_options)

          phase = Leeroy::Types::Phase.new(self.state.fetch('phase', options[:phase]))
          self.state.phase = phase

          # create image
          image_params = _genImageParams(phase)

          logger.debug "image_params: #{image_params.inspect}"

          image = Leeroy::Types::Image.new(image_params)
          resp = ec2Request(:create_image, image.run_params)

          imageid = resp.image_id
          logger.debug "imageid: #{imageid}"

          self.state.imageid = imageid

          dump_state

          logger.debug "done performing for #{self.class}"

        rescue StandardError => e
          raise e
        end
      end

      private

      def _genImageParams(phase, state = self.state, env = self.env, ec2 = self.ec2, options = self.options)
        begin
          logger.debug "generating params for creating an EC2 image"

          image_params = Leeroy::Types::Mash.new

          image_params.phase = phase

          # get instance_id from state or options
          instance_id = state.instanceid? ? state.instanceid : options[:instance]
          raise "Unable to determine instance ID, exiting." if instance_id.nil?
          logger.debug "instance_id: #{instance_id}"
          image_params.instance_id = instance_id

          # were we given an app_name?
          app_name = state.app_name? ? state.app_name : checkEnv('LEEROY_APP_NAME')
          logger.debug "app_name: #{app_name}"

          # were we given an image index?
          index = _genImageIndex(state, env, ec2, options).to_s
          logger.debug "index: #{index}"

          # build target depends on phase
          build_target = phase == 'gold_master' ? 'master' : checkEnv('LEEROY_BUILD_TARGET')

          image_params.name = [app_name, build_target, index].join('-')

          image_params

        rescue StandardError => e
          raise e
        end
      end

      def _genImageIndex(state = self.state, env = self.env, ec2 = self.ec2, options = self.options)
        begin
          logger.debug "determining gold master instance ID"

          options[:index] or getGoldMasterImageIndex

        rescue StandardError => e
          raise e
        end
      end

    end
  end
end
