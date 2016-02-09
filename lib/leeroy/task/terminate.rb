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

          if terminated.include?(self.state.instanceid)
            logger.debug "clearing instanceid #{self.state.instanceid} from state"
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
