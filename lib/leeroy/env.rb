require 'dotenv'
Dotenv.load

require 'hashie'

module Leeroy
  class Env < Hashie::Mash
    include Hashie::Extensions::MethodReader
    include Hashie::Extensions::MethodQuery
    include Hashie::Extensions::IndifferentAccess

    def initialize(env = ENV)
      super
    end

    def to_s
      _capture_stdout { ap self }
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
