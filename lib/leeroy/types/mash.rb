require 'hashie'

module Leeroy
  module Types
    class Mash < Hashie::Mash
      include Hashie::Extensions::KeyConversion
      include Hashie::Extensions::MethodAccess
      include Hashie::Extensions::IndifferentAccess
      include Hashie::Extensions::Coercion

      def dumper
        self.to_hash
      end

    end
  end
end
