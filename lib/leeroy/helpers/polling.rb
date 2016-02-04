require 'awesome_print'
require 'fire_poll'

require 'leeroy/helpers'

module Leeroy
  module Helpers
    module Polling
      include FirePoll

      include Leeroy::Helpers

      def poll_callback(callback, timeout = 10)
        begin
          logger.debug "beginning to poll"
          logger.debug "callback: #{ap callback}"
          poll(timeout) do
            callback
          end
        end
      end
    end
  end
end
