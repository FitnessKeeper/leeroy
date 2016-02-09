require 'leeroy'
require 'leeroy/env'
require 'leeroy/helpers'
require 'leeroy/state'

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

      def initialize(params = {})
        begin
          logger.debug("initializing #{self.class.to_s}")

          logger.debug("setting global_options")
          @global_options = params.fetch(:global_options, {})
          logger.debug("global_options: #{self.global_options.to_s}")

          logger.debug("setting options")
          @options = params.fetch(:options, {})
          logger.debug("options: #{self.options.to_s}")

          logger.debug("setting args")
          @args = params.fetch(:args, {})
          logger.debug("args: #{self.args.to_s}")

          logger.debug("setting env")
          @env = Leeroy::Env.new(params.fetch(:env, ENV))
          logger.debug("env: #{self.env.to_s}")

          logger.debug("setting state")
          # @state = Leeroy::State.new(params.fetch(:state, {}), global_options[:pipe])
          @state = Leeroy::State.new(
            data: params.fetch(:state, {}),
            metadata: {:current => self.class.to_s},
          )
          logger.debug("state: #{self.state}")

          logger.debug("base initialization of #{self.class.to_s} complete")
        rescue StandardError => e
          raise e
        end
      end

      def perform(args = self.args, options = self.options, global_options = self.global_options)
        begin
          self.logger.debug("performing #{self.class.to_s}")
          self.logger.debug("args: #{args.inspect}")
          self.logger.debug("options: #{options.inspect}")
        rescue StandardError => e
          raise e
        end
      end

    end
  end
end
