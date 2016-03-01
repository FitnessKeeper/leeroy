require 'leeroy'
require 'leeroy/task'
require 'leeroy/helpers/aws'
require 'leeroy/helpers/polling'
require 'leeroy/types/image'
require 'leeroy/types/phase'

module Leeroy
  module Task
    class Image < Leeroy::Task::Base
      include Leeroy::Helpers::AWS
      include Leeroy::Helpers::Polling

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

          _prepImageCreationPolling
          poll(imageid)

          dump_state

          logger.debug "done performing for #{self.class}"

        rescue StandardError => e
          raise e
        end
      end

      private

      def _prepImageCreationPolling
        # poll to make sure image is created
        self.poll_callback = lambda do |imageid|
          begin
            run_params = { :image_ids => [imageid], :owners => ['self'] }
            resp = ec2Request(:describe_images, run_params)

            state = resp.images[0].state

            if state == 'pending'
              logger.debug "image #{imageid} still pending"
              nil
            elsif state == 'available'
              logger.debug "image #{imageid} available"
              imageid
            else
              raise "image creation failed: #{resp.images[0].state_reason.message}"
            end

          rescue Aws::EC2::Errors::InvalidAMIIDNotFound => e
            logger.debug "instance #{instanceid} not found"
            nil
          rescue StandardError => e
            raise e
          end
        end

        self.poll_timeout = checkEnv('LEEROY_POLL_TIMEOUT').to_i
        self.poll_interval = checkEnv('LEEROY_POLL_INTERVAL').to_i
      end

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

          options[:index] or getGoldMasterImageIndex.to_i + 1

        rescue StandardError => e
          raise e
        end
      end

    end
  end
end
