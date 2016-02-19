require 'hashie'

module Leeroy
  module Types
    class Dash < Hashie::Dash
      include Hashie::Extensions::KeyConversion
      include Hashie::Extensions::MethodAccess
      include Hashie::Extensions::IndifferentAccess
      include Hashie::Extensions::Dash::Coercion

      def dumper
        self.to_hash
      end

    end
  end
end
