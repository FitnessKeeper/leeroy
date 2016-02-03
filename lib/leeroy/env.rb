require 'dotenv'
Dotenv.load

require 'leeroy/hashiemash'
require 'leeroy/helpers/env'

module Leeroy

  class Env < Leeroy::HashieMash
    Yell.new :stderr, :name => 'Leeroy::Env'

    include Leeroy::Helpers::Env

    def initialize(env = ENV)
      begin
        self.logger.debug "initializing #{self.class}"
        super(_filter_env(env))
      rescue StandardError => e
        raise e
      end
    end

    private

    def _filter_env(env, prefix = 'LEEROY_')
      begin
        logger.debug("filtering env by prefix '#{prefix}'")
        env.select { |k,v| k.start_with?(prefix) }

      rescue StandardError => e
        raise e
      end
    end
  end
end
