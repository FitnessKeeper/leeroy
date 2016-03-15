require 'leeroy/task'

module Leeroy
  module Task
    class Stub < Leeroy::Task::Base

      def perform(args = self.args, options = self.options, global_options = self.global_options)
        super

        begin
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

        rescue StandardError => e
          raise e
        end
      end
    end
  end
end
