require 'hashie'
require 'json'

require 'leeroy/helpers'

module Leeroy
  module Helpers
    module State
      include Leeroy::Helpers

      attr_accessor :state

      def state_from_pipe(state = {}, global_options = self.global_options)
        begin
          if global_options.fetch(:pipe, false)
            logger.debug "running in pipe mode"
            state = state.merge(load_state)
          else
            logger.debug "not running in pipe mode"
          end

          state

        rescue StandardError => e
          raise e
        end
      end

      def load_state
        begin
          logger.debug("loading state from stdin")
          lines = []

          while line = $stdin.gets do
            line.chomp!
            logger.debug "line: #{line}"
            lines.push(line)
            logger.debug "lines: #{lines.to_s}"
          end

          joined = lines.join
          logger.debug "joined: #{joined}"

          JSON.parse(joined)
        rescue StandardError => e
          raise e
        end
      end

      def dump_state
        logger.debug("dumping state to stdout")
        self.state.metadata.previous = self.state.metadata.task
        $stdout.puts self.state.to_json
      end

      def to_s
        "#{self.metadata},#{self.data}"
      end
    end
  end
end
