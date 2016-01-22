require 'leeroy'
require 'leeroy/task/base'

require 'yell'

module Leeroy
  module Task
    include Leeroy::Helpers
    include Leeroy::Helpers::Env
    include Leeroy::Helpers::State
    attr_reader :params

    attr :state

  end
end
