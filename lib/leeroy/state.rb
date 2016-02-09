require 'leeroy/types/dash'
require 'leeroy/types/statedata'
require 'leeroy/types/statemetadata'
require 'leeroy/helpers/polling'
require 'leeroy/helpers/state'

module Leeroy
  Yell.new :stderr, :name => 'Leeroy::State'

  class State < Leeroy::Types::Dash
    include Yell::Loggable

    include Leeroy::Helpers::Polling
    include Leeroy::Helpers::State

    # state properties
    property :data, coerce: Leeroy::Types::StateData
    property :metadata, coerce: Leeroy::Types::StateMetadata

    def fetch(*args, &block)
      begin
        self.data.send(:fetch, *args, &block)

      rescue KeyError => e
        logger.debug e.message
        self.send(:fetch, *args, &block)

      rescue StandardError => e
        raise e
      end
    end

    def method_missing(method, *args, &block)
      begin
        self.data.send(method.to_sym, *args, &block)

      rescue NoMethodError => e
        logger.debug e.message
        if self.respond_to?(method.to_sym)
          self.send(method.to_sym, *args, &block)
        else
          raise e
        end

      rescue StandardError => e
        raise e
      end
    end

    # def initialize(state = {}, pipe = false)
    #   begin
    #     logger.debug "initializing #{self.class}"
    #
    #     if pipe
    #       logger.debug "running in pipe mode"
    #       state = state.merge(load_state)
    #     else
    #       logger.debug "not running in pipe mode"
    #     end
    #
    #     logger.debug "initializing with state: #{state.inspect}"
    #
    #     super(state)
    #
    #   rescue StandardError => e
    #     raise e
    #   end
    # end
  end
end
