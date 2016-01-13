require 'leeroy'

module Leeroy
  module Helpers
    class Base
      def env
        Leeroy::Env.new
      end
    end

    private

    def _capture_stdout
      begin
        old_stdout = $stdout
        $stdout = StringIO.new('','w')
        yield
        $stdout.string
      ensure
        $stdout = old_stdout
      end
    end

  end
end
