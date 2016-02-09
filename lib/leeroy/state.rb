require 'leeroy/types/dash'
require 'leeroy/helpers/polling'
require 'leeroy/helpers/state'

module Leeroy
  Yell.new :stderr, :name => 'Leeroy::State'

  class State < Leeroy::Types::Dash
    include Yell::Loggable

    include Leeroy::Helpers::Polling
    include Leeroy::Helpers::State

    # state properties
    property :current_task
    property :previous_task, default: nil

    def initialize(state = {}, pipe = false)
      begin
        logger.debug "initializing #{self.class}"

        if pipe
          logger.debug "running in pipe mode"
          state = state.merge(load_state)
        else
          logger.debug "not running in pipe mode"
        end

        logger.debug "initializing with state: #{state.inspect}"

        super(state)

      rescue StandardError => e
        raise e
      end
    end
  end
end
