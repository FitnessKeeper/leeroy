require 'chronic'
require 'yell'

require 'leeroy/helpers/logging'
require 'leeroy/types/dash'

module Leeroy
  module Types
    class StateMetadata < Leeroy::Types::Dash
      include Leeroy::Helpers::Dumpable
      include Leeroy::Helpers::Logging

      property :task, default: nil
      property :previous, default: nil
      property :started, coerce: Proc.new { |t| Chronic.parse(t) }, default: 'now'

      def initialize(*args, &block)
        super

        self.dump_properties = [
          :task,
          :previous,
          :started,
        ]
      end

    end
  end
end
