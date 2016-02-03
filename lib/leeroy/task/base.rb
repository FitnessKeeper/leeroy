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
      include Leeroy::Helpers::Env
      include Leeroy::Helpers::State

      def initialize(args = {})
        begin
          logger.debug("initializing #{self.class.to_s}")

          logger.debug("setting params")
          @params = args
          logger.debug("params: #{self.params.to_s}")

          logger.debug("setting env")
          @env = Leeroy::Env.new
          logger.debug("env: #{self.env.to_s}")

          logger.debug("setting state")
          @state = load_state(args.fetch(:state, {}))
          logger.debug("state: #{self.state.to_s}")

          logger.debug("initialization of #{self.class.to_s} complete")
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
