require 'hashie'

module Leeroy
  module Types
    class Mash < Hashie::Mash
      include Hashie::Extensions::MethodReader
      include Hashie::Extensions::MethodQuery
      include Hashie::Extensions::IndifferentAccess
      include Hashie::Extensions::Coercion
    end
  end
end
