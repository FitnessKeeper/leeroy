require 'leeroy/helpers/dumpable'
require 'leeroy/types/packedstring'
require 'leeroy/types/dash'

module Leeroy
  module Types
    class Semaphore < Leeroy::Types::Dash
      include Leeroy::Helpers::Dumpable

      property :bucket
      property :object
      property :payload

      def initialize(*args, &block)
        super

        self.dump_properties = [
          :bucket,
          :object,
          :payload,
        ]
      end

      def to_s
        "s3://#{self.bucket}/#{self.object}"
      end

    end
  end
end
