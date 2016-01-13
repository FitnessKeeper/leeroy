require 'awesome_print'

require 'leeroy/helpers'

module Leeroy
  module Helpers
    class Env < Leeroy::Helpers::Base

      def to_s(obj)
        _capture_stdout { ap obj }
      end
    end
  end
end
