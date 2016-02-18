require 'leeroy'
require 'leeroy/types/dash'
require 'leeroy/types/mash'
require 'leeroy/helpers/logging'

module Leeroy
  module Types
    class Image < Leeroy::Types::Dash
      include Leeroy::Helpers::Logging

      property :phase, required: true

      # AWS-specific params
      property :instance_id, required: true
      property :name, required: true

      def run_params
        begin
          run_params = Leeroy::Types::Mash.new

          [
            :instance_id,
            :name,
          ].map {|key| run_params.store(key.to_s, self.fetch(key))}

          logger.debug "run_params: #{run_params.inspect}"

          run_params

        rescue StandardError => e
          raise e
        end
      end

    end
  end
end
