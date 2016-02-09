require 'yell'

require 'leeroy/helpers'

module Leeroy
  module Helpers
    module Logging
      include Leeroy::Helpers

      # constants
      Trace_Format = '%d [%5L] %p (%M): %m'
      Trace_Levels = [:debug]

      # define a logger
      Yell.new :stderr, name: self.class.to_s, format: Trace_Format, trace: Trace_Levels

      # make this class loggable
      self.class.send :include, Yell::Loggable

      # make logger an instance method
      def logger
        self.class.logger
      end

    end
  end
end
