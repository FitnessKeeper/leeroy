require 'dotenv'
Dotenv.load

require 'leeroy/types/mash'
require 'leeroy/helpers/env'
require 'leeroy/helpers/logging'

module Leeroy
  class Env < Leeroy::Types::Mash
    include Leeroy::Helpers::Env
    include Leeroy::Helpers::Logging

    # constants
    S3_PREFIXES = {
      :secrets    => 'secrets',
      :jenkins    => 'jenkins',
      :builds     => 'builds',
      :logs       => 'logs',
      :semaphores => 'semaphores',
      :tests      => 'tests',
    }

    def initialize(env = ENV)
      begin
        logger.debug "initializing #{self.class}"
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
