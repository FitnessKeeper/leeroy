require 'leeroy'
require 'leeroy/env'
require 'leeroy/helpers'
require 'leeroy/helpers/env'
require 'leeroy/helpers/logging'
require 'leeroy/helpers/state'
require 'leeroy/state'
require 'leeroy/task'
require 'leeroy/types/mash'

module Leeroy
  module Task
    class Base

      include Leeroy::Task
      include Leeroy::Helpers
      include Leeroy::Helpers::Env
      include Leeroy::Helpers::Logging
      include Leeroy::Helpers::State

      def initialize(params = {})
        begin
          @global_options = params.fetch(:global_options, {})
          @options = params.fetch(:options, {})
          @args = params.fetch(:args, {})

          @env = Leeroy::Env.new({}, params.fetch(:env, ENV))

          @state = Leeroy::State.new(state_from_pipe(params.fetch(:state, {})))
          rotate_task_metadata

        rescue StandardError => e
          raise e
        end
      end

      def perform(args = self.args, options = self.options, global_options = self.global_options)
        begin
          self.logger.info("performing #{self.class.to_s}")
          self.logger.debug("args: #{args.inspect}")
          self.logger.debug("options: #{options.inspect}")
          self.logger.debug("global_options: #{global_options.inspect}")

        rescue StandardError => e
          raise e
        end
      end
    end
  end
end
