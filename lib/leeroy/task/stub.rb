require 'leeroy/task'

module Leeroy
  module Task
    class Stub < Leeroy::Task::Base

      def perform(params = {})
        super(params)

        begin
          logger.debug("performing for #{self.class}")
          logger.debug("state: #{self.state}")
          message = self.state.message

          logger.info("old message: #{message}")

          if message.nil?
            message = 1
          else
            message = message + 1
          end

          state.message = message

          logger.info("new message: #{message}")

          dump_state

        rescue StandardError => e
          raise e
        end
      end
    end
  end
end
