require 'leeroy'
require 'leeroy/types/dash'
require 'leeroy/types/mash'
require 'leeroy/helpers/logging'

module Leeroy
  module Types
    class Runnable < Leeroy::Types::Dash
      include Leeroy::Helpers::Logging

      property :params, default: [], coerce: Array[Symbol]
      property :command, default: :'', coerce: Symbol
      property :retrievals, default: {}, coerce: Hash[Symbol => Proc]

      def run_params
        begin
          run_params = Leeroy::Types::Mash.new

          self.params.map do |key|
            retrieval = self.retrievals.fetch(key, lambda {|x,y| x.fetch(y)})
            run_params.store(key.to_s, retrieval.call(self,key))
          end

          logger.debug "run_params: #{run_params.inspect}"

          run_params

        rescue StandardError => e
          raise e
        end
      end

    end
  end
end
