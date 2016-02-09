require 'leeroy/task'

module Leeroy
  module Task
    class Sleep < Leeroy::Task::Base

      def perform(args = self.args, options = self.options, global_options = self.global_options)
        super(args, options, global_options)

        begin
          logger.debug "performing for #{self.class}"
          logger.debug "state: #{self.state}"

          interval = self.options[:interval].to_i
          logger.debug "sleeping: #{interval} seconds"

          sleep interval

          dump_state

          logger.debug "done performing for #{self.class}"

        rescue StandardError => e
          raise e
        end
      end
    end
  end
end
