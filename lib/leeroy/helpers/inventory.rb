# Helper methods for managing inventory (images, instances, etc.)
#
require 'leeroy/helpers'
require 'leeroy/helpers/aws'
require 'leeroy/helpers/logging'

module Leeroy
  module Helpers
    module Inventory
      include Leeroy::Helpers::AWS
      include Leeroy::Helpers::Logging

      # determine the name of an AMI to use in creating an instance
      def genImageName(phase = nil, state = self.state, options = self.options)
        begin
          # extract phase from state if not provided
          phase = state.phase if phase.nil?

          # were we given an app_name?
          app_name = state.app_name? ? state.app_name : checkEnv('LEEROY_APP_NAME')
          logger.debug "app_name: #{app_name}"

          # build target depends on phase
          build_target = case phase
          when 'gold_master'
            'master'
          when 'application'
            checkEnv('LEEROY_BUILD_TARGET')
          else
            raise "No phase provided in state data, exiting."
          end

          # were we given an image index?
          index = genImageIndex(state, self.env, self.ec2, options).to_s
          logger.debug "index: #{index}"

          image_name = [app_name, build_target, index].join('-')

          logger.debug "image_name: #{image_name}"

          image_name

        rescue StandardError => e
          raise e
        end
      end

      def genImageIndex(state = self.state, env = self.env, ec2 = self.ec2, options = self.options)
        begin
          index = options[:index]

          if index
            logger.debug "index provided: #{index}"
          else
            logger.debug "index not provided, calculating"
            phase = state.phase

            index = case phase
            when 'gold_master'
              getGoldMasterImageIndex.to_i + 1
            when 'application'
              getGoldMasterImageIndex.to_i
            else
              raise "unable to determine image index for phase '#{phase.to_s}'"
            end
          end

          logger.debug "index: #{index}"

          index

        rescue StandardError => e
          raise e
        end
      end

    end
  end
end
