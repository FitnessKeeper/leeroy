require 'leeroy/task'

module Leeroy
  module Task
    class GetState < Leeroy::Task::Base
      include Leeroy::Helpers::State

      def initialise(*)
        super
      end

      def perform(params)
        super
        self.state
      end

    end
  end
end
