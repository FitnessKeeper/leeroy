require 'leeroy'

module Leeroy
  module Helpers
    class Base
      def env
        Leeroy::Env.new
      end
    end
  end
end
