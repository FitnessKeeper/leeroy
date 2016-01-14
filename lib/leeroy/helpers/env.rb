require 'awesome_print'

require 'leeroy/env'
require 'leeroy/helpers'

module Leeroy
  module Helpers
    module Env
      include Leeroy::Helpers

      attr :env

      def initialize_env
        begin
          @env = Leeroy::Env.new
        rescue StandardError => e
          raise e
        end
      end

    end
  end
end
