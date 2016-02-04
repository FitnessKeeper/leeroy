require 'leeroy'
require 'leeroy/task/base'

module Leeroy
  module Task
    include Leeroy::Helpers
    include Leeroy::Helpers::Env
    include Leeroy::Helpers::State
    attr_reader :global_options, :options, :args

    attr :state

  end
end
