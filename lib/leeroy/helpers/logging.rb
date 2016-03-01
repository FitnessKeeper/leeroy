require 'yell'
require 'yell-adapters-syslog'

require 'leeroy/helpers'
require 'leeroy/helpers/env'

module Leeroy
  module Helpers
    module Logging
      include Leeroy::Helpers

      # constants
      TRUNCATE_THRESHOLD = 60

      TRACE_FORMAT = "%d [%5L] %p (%M): %m"
      TRACE_LEVELS = [:debug]

      # define a logger
      # Yell.new :stderr, name: self.class.to_s, format: TRACE_FORMAT, trace: TRACE_LEVELS, level: :debug
      if ENV['ENVIRONMENT'] == 'production'
        Yell.new :syslog, name: self.class.to_s, format: TRACE_FORMAT, trace: TRACE_LEVELS, level: :info
      else
        Yell.new :stderr, name: self.class.to_s, format: TRACE_FORMAT, trace: TRACE_LEVELS, level: :debug
      end

      # make this class loggable
      self.class.send :include, Yell::Loggable

      # make logger an instance method
      def logger
        self.class.logger
      end

    end
  end
end
