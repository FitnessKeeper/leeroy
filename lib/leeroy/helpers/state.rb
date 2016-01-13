require 'hashie'
require 'tempfile'

require 'leeroy/helpers'

module Leeroy
  module Helpers
    class State < Hashie::Dash
      include Hashie::Extensions::Dash::Coercion

      property :statefile, default: Leeroy::Env.new.LEEROY_STATEFILE
      property :state, coerce: Hashie::Mash, default: {}

      def to_s
        state.to_s
      end

      def respond_to?(method)
        state.respond_to?(method.to_sym) || super
      end

      def method_missing(method, *args, &blk)
        state.send(method.to_sym, *args, &blk)
      end
    end
  end
end
