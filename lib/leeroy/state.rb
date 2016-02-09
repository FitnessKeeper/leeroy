require 'leeroy/types/dash'
require 'leeroy/types/statedata'
require 'leeroy/types/statemetadata'
require 'leeroy/helpers/logging'
require 'leeroy/helpers/polling'
require 'leeroy/helpers/state'

module Leeroy
  class State < Leeroy::Types::Dash
    include Leeroy::Helpers::Logging
    include Leeroy::Helpers::Polling
    include Leeroy::Helpers::State

    # state properties
    property :data, coerce: Leeroy::Types::StateData, default: {}
    property :metadata, coerce: Leeroy::Types::StateMetadata, default: {}

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
  end
end
