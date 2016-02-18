require 'leeroy/types/packedstring'
require 'leeroy/types/dash'

module Leeroy
  module Types
    class Semaphore < Leeroy::Types::Dash

      property :bucket
      property :object
      property :payload, coerce: Leeroy::Types::PackedString

      def to_s
        "s3://#{self.bucket}/#{self.object}"
      end

      def dump
        self.payload.extract
      end

    end
  end
end
