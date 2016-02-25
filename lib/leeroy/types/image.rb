require 'leeroy'
require 'leeroy/types/dash'
require 'leeroy/types/mash'
require 'leeroy/helpers/dumpable'
require 'leeroy/helpers/logging'

module Leeroy
  module Types
    class Image < Leeroy::Types::Dash
      include Leeroy::Helpers::Dumpable
      include Leeroy::Helpers::Logging

      property :phase, required: true
      property :aws_params

      # AWS-specific params
      property :image_id, required: true
      property :name, required: true

      def initialize(*args, &block)
        self.aws_params = [
          :instance_id,
          :name,
        ]

        self.dump_properties = self.aws_params

        super
      end

      def run_params
        begin
          run_params = Leeroy::Types::Mash.new

          self.aws_params.each {|key| run_params.store(key.to_s, self.fetch(key))}

          logger.debug "run_params: #{run_params.inspect}"

          run_params

        rescue StandardError => e
          raise e
        end
      end

      def to_s
        self.image_id
      end

    end
  end
end
