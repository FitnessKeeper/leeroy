require 'dotenv'
Dotenv.load

require 'hashie'

class Leeroy::Env < Hashie::Mash
  include Hashie::Extensions::MethodReader
  include Hashie::Extensions::MethodQuery
  include Hashie::Extensions::IndifferentAccess

  def initialize(env = ENV)
    super
  end
end
