require 'leeroy/task'
require 'leeroy/helpers/aws'
require 'leeroy/helpers/polling'

module Leeroy
  module Task
    class PollInstance < Leeroy::Task::Base
      include Leeroy::Helpers::AWS
      include Leeroy::Helpers::Polling

      def perform(args = self.args, options = self.options, global_options = self.global_options)
        super(args, options, global_options)

        begin
          logger.debug "performing for #{self.class}"
          logger.debug "state: #{self.state}"

          # instanceid comes from state or options
          instanceid = self.state.instanceid
          if instanceid.nil?
            instanceid = self.options[:instance]
          end

          logger.debug "instanceid: #{instanceid}"

          # did we get a semaphore in state?
          if self.state.semaphore?
            semaphore = self.state.semaphore
          else
            # build the semaphore from provided instance
            s3_object = buildS3ObjectName(instanceid, 'semaphores')
            semaphore = genSemaphore(s3_object, '')
          end

          logger.debug "semaphore: #{semaphore.inspect}"

          # configure polling
          self.poll_callback = lambda {|s| checkSemaphore(s).nil?}
          self.poll_timeout = checkEnv('LEEROY_POLL_TIMEOUT').to_i
          self.poll_interval = checkEnv('LEEROY_POLL_INTERVAL').to_i

          poll(semaphore)

          dump_state

          logger.debug "done performing for #{self.class}"

        rescue StandardError => e
          raise e
        end
      end
    end
  end
end
