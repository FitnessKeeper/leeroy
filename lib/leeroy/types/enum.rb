require 'typesafe_enum'

require 'leeroy/helpers/logging'

module Leeroy
  module Types
    ##
    # Implements the [Typesafe Enum
    # pattern](http://www.oracle.com/technetwork/java/page1-139488.html#replaceenums).
    # Implement your own classes that inherit from this.
    #
    # Valid values for these enums must be Strings or otherwise stringifiable.
    #
    # Usage:
    # ```
    # class EnumClass < Leeroy::Types::Enum
    #   # 'foo' and 'bar' are the only acceptable values for EnumClass
    #   new :FOO
    #   new :BAR
    # end
    #
    # enum_valid = Leeroy::Types::EnumClass.resolve('foo')
    # # returns a valid instance of Leeroy::Types::EnumClass::FOO
    # enum_valid.to_s
    # # returns 'foo'
    # enum_invalid = Leeroy::Types::EnumClass.resolve('baz')
    # # raises an exception
    # ```
    #
    class Enum < TypesafeEnum::Base

      def to_s
        self.value
      end

      ##
      # Given a string or something that can be stringified, returns a subclass
      # of the parent enum with a value matching the provided string.
      #
      # Accepts an optional second argument; if the first argument cannot be
      # resolved by the enum, the second argument will be resolved.
      #
      def self.resolve(candidate, alternate = nil)
        resolved = candidate.kind_of?(Leeroy::Types::Enum) ? candidate : self.from_s(candidate)

        if candidate.nil?
          resolved = self.resolve(alternate, nil) unless alternate.nil?
        end

        # FIXME raise some more appropriate type of error
        raise "invalid value for enum" if resolved.nil?

        resolved
      end

      def resolve(candidate, alternate = nil)
        self.resolve(candidate, alternate)
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
