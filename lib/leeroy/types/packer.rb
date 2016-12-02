require 'leeroy'
require 'leeroy/types/dash'
require 'leeroy/types/phase'
require 'leeroy/helpers/dumpable'
require 'leeroy/helpers/logging'

module Leeroy
  module Types
    class Packer < Leeroy::Types::Dash
      include Leeroy::Helpers::Dumpable
      include Leeroy::Helpers::Logging

      property :app_name, coerce: String
      property :aws_linux_ami, coerce: String
      property :aws_region, coerce: String
      property :packer_vars
      property :packer_template_prefix

      def initialize(*args, &block)
        self.packer_vars = [
          :aws_linux_ami,
          :app_name,
          :aws_region,
          :packer_template_prefix
        ]

        self.dump_properties = self.packer_vars

        super
      end
    end
  end
end
