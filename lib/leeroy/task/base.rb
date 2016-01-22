require 'leeroy'
require 'leeroy/helpers'
require 'leeroy/helpers/state'

require 'hashie'
require 'yell'

module Leeroy
  module Task
    trace_levels = [:debug]
    Yell.new :stderr, :name => 'Leeroy::Task::Base', :trace => trace_levels

    class Base
      include Yell::Loggable

      include Leeroy::Task
      include Leeroy::Helpers
      include Leeroy::Helpers::State

      def initialize(params = {})
        begin
          self.logger.debug("initializing #{self.class.to_s}")

          self.logger.debug("setting params")
          @params = params
          self.logger.debug("params: #{self.params.to_s}")

          self.logger.debug("setting env")
          @env = Leeroy::Env.new
          self.logger.debug("env: #{self.env.to_s}")

          self.logger.debug("setting state")
          @state = Leeroy::Helpers::State.load(self.env.LEEROY_STATEFILE)
          self.logger.debug("state: #{self.state.to_s}")

          self.logger.debug("initialization of #{self.class.to_s} complete")
        rescue StandardError => e
          raise e
        end
      end

      def perform(params = self.params)
        begin
          self.logger.debug("performing #{self.class.to_s}")
          self.logger.debug("params: #{params.inspect}")
        rescue StandardError => e
          raise e
        end
      end

    end
  end
end
