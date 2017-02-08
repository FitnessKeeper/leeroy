require 'leeroy'
require 'leeroy/types/dash'
require 'leeroy/types/phase'
require 'leeroy/helpers/dumpable'
require 'leeroy/helpers/logging'

module Leeroy
  module Types
    class StaticAssets < Leeroy::Types::Dash
      include Leeroy::Helpers::Dumpable
      include Leeroy::Helpers::Logging

      property :static_assets_vars
      property :static_asssets_path, coerce: String
      property :static_asssets_s3_prefix, coerce: String
      property :static_asssets_s3_bucket, coerce: String
      property :aws_region, coerce: String

      def initialize(*args, &block)
        self.static_assets_vars = [
          :static_asssets_path,
          :static_asssets_s3_prefix,
          :static_asssets_s3_bucket,
          :aws_region
        ]

        self.dump_properties = self.static_assets_vars

        super
      end
    end
  end
end
