require 'dotenv'
Dotenv.load

require 'hashie'
require 'yell'

require 'leeroy/helpers/env'

module Leeroy
  Yell.new :stderr, :name => 'Leeroy::Env'

  class Env < Hashie::Mash
    include Hashie::Extensions::MethodReader
    include Hashie::Extensions::MethodQuery
    include Hashie::Extensions::IndifferentAccess

    include Yell::Loggable

    include Leeroy::Helpers::Env

    def initialize(env = ENV)
      self.logger.debug "initializing #{self.class.to_s}"
      super
    end
  end
end
