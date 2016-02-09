require 'hashie'

module Leeroy
  module Types
    class Dash < Hashie::Dash
      include Hashie::Extensions::MethodReader
      include Hashie::Extensions::MethodQuery
      include Hashie::Extensions::IndifferentAccess
      include Hashie::Extensions::Dash::Coercion
    end
  end
end
