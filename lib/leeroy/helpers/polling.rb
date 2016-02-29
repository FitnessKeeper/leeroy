require 'smart_polling'

require 'leeroy/helpers'
require 'leeroy/helpers/env'
require 'leeroy/types/mash'

module Leeroy
  module Helpers
    module Polling
      include Leeroy::Helpers
      include Leeroy::Helpers::Env

      POLL_CALLBACK = lambda {|x| raise 'this is the default callback, did you forget to set the poll_callback attribute?'}
      POLL_TIMEOUT = 600 # seconds
      POLL_INTERVAL = 10 # seconds

      attr_accessor :poll_callback, :poll_timeout, :poll_interval, :poll_response

      def poll(*args)
        begin
          logger.debug "beginning to poll"

          callback = self.poll_callback
          raise "callback must be a Proc" unless callback.kind_of?(Proc)

          timeout = self.poll_timeout
          interval = self.poll_interval

          logger.debug "callback: #{callback.inspect}"
          logger.debug "polling every #{interval} seconds for #{timeout} seconds"

          SmartPolling.poll(timeout: timeout, interval: interval) do
            logger.debug "polling"
            poll_arg = args[0]
            logger.debug "poll_arg: #{poll_arg.inspect}"
            self.poll_response = callback.call(poll_arg)
          end

          response = self.poll_response
          logger.debug "response: #{response.inspect}"

          response

        rescue Interrupt => e
          logger.fatal "Keyboard interrupt"
          raise e

        rescue StandardError => e
          raise e
        end
      end

      def initialize(*args, &block)
        begin
          super

          @poll_callback = POLL_CALLBACK
          @poll_timeout = POLL_TIMEOUT
          @poll_interval = POLL_INTERVAL

        rescue StandardError => e
          raise e
        end
      end

    end
  end
end
