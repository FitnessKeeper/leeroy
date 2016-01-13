require 'dotenv'
Dotenv.load

require 'hashie'

require 'leeroy/helpers/env'

module Leeroy
  class Env < Hashie::Mash
    include Hashie::Extensions::MethodReader
    include Hashie::Extensions::MethodQuery
    include Hashie::Extensions::IndifferentAccess

    def initialize(env = ENV)
      super
    end

    def to_s
      Leeroy::Helpers::Env.to_s(self)
    end
  end
end
