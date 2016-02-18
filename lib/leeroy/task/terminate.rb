require 'leeroy'
require 'leeroy/task'
require 'leeroy/helpers/aws'

module Leeroy
  module Task
    class Terminate < Leeroy::Task::Base
      include Leeroy::Helpers::AWS

      def perform(args = self.args, options = self.options, global_options = self.global_options)
        begin
          super(args, options, global_options)

          # destroy instance
          terminated = destroyInstance

          instanceid = self.state.instanceid
          if terminated.include?(instanceid)
            # clean up semaphore if present
            semaphore = self.state.semaphore

            if semaphore.nil?
              # guess at semaphore from instance ID
              s3_object = buildS3ObjectName(instanceid, 'semaphores')
              bucket = checkEnv('LEEROY_S3_BUCKET')
              semaphore = Leeroy::Types::Semaphore.new(bucket: bucket, object: s3_object, payload: '')
            end

            unless semaphore.nil?
              logger.debug "clearing semaphore #{semaphore}"
              clearSemaphore(semaphore)
            end

            logger.debug "clearing instanceid #{instanceid} from state"
            self.state.instanceid = nil
          end

          dump_state

          logger.debug "done performing for #{self.class}"

        rescue StandardError => e
          raise e
        end
      end

    end
  end
end
