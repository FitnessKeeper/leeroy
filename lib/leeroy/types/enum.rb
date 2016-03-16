require 'typesafe_enum'

require 'leeroy/helpers/logging'

module Leeroy
  module Types
    class Enum < TypesafeEnum::Base

      def to_s
        self.value
      end

      def self.from_s(x)
        self.find_by_value_str(x.to_s)
      end

      def from_s(x)
        self.from_s(x)
      end

    end
  end
end
