require 'dotenv'
Dotenv.load

require 'hashie'

require 'leeroy/helpers/env'

module Leeroy
  class Env < Hashie::Mash
    include Hashie::Extensions::MethodReader
    include Hashie::Extensions::MethodQuery
    include Hashie::Extensions::IndifferentAccess

    include Leeroy::Helpers::Env

    def initialize(env = ENV)
      super
    end

    def to_s(obj)
      _capture_stdout { ap obj }
    end
  end
end
