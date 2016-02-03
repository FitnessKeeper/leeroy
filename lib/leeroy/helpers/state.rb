require 'hashie'
require 'json'

require 'leeroy/hashiemash'
require 'leeroy/helpers'

module Leeroy
  module Helpers
    module State
      include Leeroy::Helpers

      attr_accessor :state

      def load_state(input)
        logger.debug("loading state from '#{input}' (#{input.class})")
        Leeroy::Helpers::State::StateHash.new(input)
      end

      def dump_state
        self.state.to_s
      end

      class StateHash < Leeroy::HashieMash
        coerce_value Hash, StateHash

        def initialize(hash = {})
          super
          hash.each_pair do |k,v|
            self[k] = v
          end
        end
      end
    end
  end
end
