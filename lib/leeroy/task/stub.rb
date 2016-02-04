require 'leeroy/task'

module Leeroy
  module Task
    class Stub < Leeroy::Task::Base

      def perform(params = {})
        super(params)

        begin
          logger.debug "performing for #{self.class}"
          logger.debug "state: #{self.state}"
          message = self.state.message

          increment = self.options[:increment].to_i
          logger.debug "increment: #{increment}"

          logger.info "old message: #{message}"

          if message.nil?
            message = increment
          else
            message = message.to_i + increment
          end

          state.message = message

          logger.info "new message: #{message}"

          dump_state

          logger.debug "done performing for #{self.class}"

        rescue StandardError => e
          raise e
        end
      end
    end
  end
end
