require 'awesome_print'

require 'leeroy/env'
require 'leeroy/helpers'

module Leeroy
  module Helpers
    module Env
      include Leeroy::Helpers

      attr_reader :env

    end
  end
end
