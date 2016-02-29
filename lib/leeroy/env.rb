require 'dotenv'
Dotenv.load

require 'leeroy/types/mash'
require 'leeroy/helpers/dumpable'
require 'leeroy/helpers/env'
require 'leeroy/helpers/logging'

module Leeroy
  class Env < Leeroy::Types::Mash
    include Leeroy::Helpers::Dumpable
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
        filtered = _filter_env(env)
        logger.debug "filtered: #{filtered.inspect}"
        self.dump_properties = filtered.keys.sort.collect { |x| x.to_sym }
        super(filtered)

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
