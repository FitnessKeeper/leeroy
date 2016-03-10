require 'leeroy/helpers/logging'

module Leeroy
  module Types
    class Phase < String
      include Leeroy::Helpers::Logging

      VALID_PHASE = ['gold_master', 'application', 'db_worker']

      def initialize(*args, &block)
        begin
          super

          phase = self.to_s
          raise "invalid value for phase: '#{phase}'" unless VALID_PHASE.include?(phase)

        rescue TypeError => e
          raise "invalid value for phase: #{e.message}"

        rescue StandardError => e
          raise e
        end
      end

    end
  end
end
