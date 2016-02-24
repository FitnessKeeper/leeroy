require 'fcntl'
require 'multi_json'

require 'leeroy/helpers'

module Leeroy
  module Helpers
    module State
      include Leeroy::Helpers

      attr_accessor :state

      def state_from_pipe(state = {}, global_options = self.global_options)
        begin
          state.merge(load_state)

        rescue StandardError => e
          raise e
        end
      end

      def load_state
        begin
          logger.debug "loading state from stdin if available"

          _stdin? ?  MultiJson.load($stdin.read, :symbolize_keys => true) : {}

        rescue StandardError => e
          raise e
        end
      end

      def dump_state
        logger.debug "dumping state to stdout"
        $stdout.puts self.state.dump
      end

      def rotate_task_metadata
        logger.debug "rotating task metadata"
        if self.state.metadata.task?
          self.state.metadata.previous = self.state.metadata.task
        end
        self.state.metadata.task = self.class.to_s
      end

      def to_s
        "#{self.metadata},#{self.data}"
      end

      private

      # this is preposterous BS and doubtless not portable to Windows
      def _stdin?
        $stdin.fcntl(Fcntl::F_GETFL, 0) == 0
      end

    end
  end
end
