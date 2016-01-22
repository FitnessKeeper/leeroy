require 'hashie'
require 'json'
require 'tempfile'

require 'leeroy/helpers'

module Leeroy
  module Helpers
    module State
      include Leeroy::Helpers
      # include Hashie::Extensions::Dash::Coercion

      # property :statefile, default: Leeroy::Env.new.LEEROY_STATEFILE
      # property :state, coerce: Hashie::Mash, default: {}

      # def self.to_s
      #   state.to_s
      # end
      #
      # def self.to_json
      #   state.to_json
      # end
      #
      # def self.respond_to?(method)
      #   state.respond_to?(method.to_sym) || super
      # end
      #
      # def self.method_missing(method, *args, &blk)
      #   state.send(method.to_sym, *args, &blk)
      # end

      def self.load(file)
        begin
          File.open(file, 'r') do |f|
            _from_json(f.gets)
          end
        rescue StandardError => e
          raise e
        end
      end

      def save(state, file = statefile)
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

      def initialize(*)
        super
        begin
          self.load
        rescue StandardError => e
          raise e
        end
      end

      private

      def self._to_json(input)
        begin
          json = input.to_json
        rescue StandardError => e
          raise e
        end
      end

      def self._from_json(input)
        begin
          JSON.parse(input)
        rescue StandardError => e
          raise e
        end
      end
    end
  end
end
