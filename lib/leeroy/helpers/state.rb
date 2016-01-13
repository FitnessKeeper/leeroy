require 'hashie'
require 'tempfile'

require 'leeroy/helpers'

module Leeroy
  module Helpers
    class State < Hashie::Dash
      include Hashie::Extensions::Dash::Coercion

      property :statefile, default: Leeroy::Env.new.LEEROY_STATEFILE
      property :state, coerce: Hashie::Mash, default: {}
    end
  end
end
