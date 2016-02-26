module Leeroy
  module Types
    class Phase < String
      VALID_PHASE = ['gold_master', 'application']

      def initialize(*args, &block)
        begin
          super

          phase = self.to_s
          raise "invalid value for phase: '#{phase}'" unless VALID_PHASE.include(phase)

        rescue StandardError => e
          raise e
        end
      end

    end
  end
end
