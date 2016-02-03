require 'hashie'

module Leeroy
  class HashieMash < Hashie::Mash
    include Hashie::Extensions::MethodReader
    include Hashie::Extensions::MethodQuery
    include Hashie::Extensions::IndifferentAccess
    include Hashie::Extensions::Coercion
  end
end
