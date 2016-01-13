require 'hashie'
require 'json'
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

      def to_json
        state.to_json
      end

      def respond_to?(method)
        state.respond_to?(method.to_sym) || super
      end

      def method_missing(method, *args, &blk)
        state.send(method.to_sym, *args, &blk)
      end

      def load(file = statefile)
        begin
          File.open(file, 'r') do |f|
            json = _from_json(f.gets)
          end
        rescue StandardError => e
          raise e
        end

        begin
          state = json
        rescue StandardError => e
          raise e
        end

        json
      end

      def save(file = statefile)
        begin
          File.new(file, 'w')
        rescue StandardError => e
          raise e
        end

        begin
          File.open(file, 'w') do |f|
            f.puts _to_json(state)
          end
        rescue StandardError => e
          raise e
        end

        file
      end

      private

      def _to_json(input)
        begin
          json = input.to_json
        rescue StandardError => e
          raise e
        end
      end

      def _from_json(input)
        begin
          JSON.parse(input)
        rescue StandardError => e
          raise e
        end
      end
    end
  end
end
