require 'hashie'
require 'json'

require 'leeroy/hashiemash'
require 'leeroy/helpers'

module Leeroy
  module Helpers
    module State
      include Leeroy::Helpers

      attr_accessor :state

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
        $stdout.puts self.state.to_json
      end
    end
  end
end
