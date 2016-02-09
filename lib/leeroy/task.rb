require 'leeroy'
require 'leeroy/helpers'
require 'leeroy/helpers/env'
require 'leeroy/helpers/logging'
require 'leeroy/helpers/state'
require 'leeroy/task/base'

module Leeroy
  module Task
    include Leeroy::Helpers
    include Leeroy::Helpers::Env
    include Leeroy::Helpers::State
    include Leeroy::Helpers::Logging
    attr_reader :global_options, :options, :args

    attr :state

  end
end
