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

    attr_reader :profile

    def initialize(options = {}, env = ENV)
      begin
        logger.debug "initializing #{self.class}"

        @profile = options[:profile]

        filtered = _filterEnv(env)
        logger.debug "filtered: #{filtered.inspect}"
        self.dump_properties = filtered.keys.sort.collect { |x| x.to_sym }
        super(filtered)

      rescue StandardError => e
        raise e
      end
    end

    def to_s
      _prettyPrint
    end

    private

    def _prettyPrint
      if self.profile
        formatstr = 'export %s=%s'
        header = '# environment variables for leeroy configuration'
      else
        formatstr = '%s=%s'
        header = nil
      end

      properties = self.dump_properties.collect {|x| x.to_s}.sort.collect {|x| sprintf(formatstr, x, self.fetch(x))}

      properties.unshift(header) unless header.nil?

      properties.join("\n")
    end

    def _filterEnv(env, prefix = 'LEEROY_')
      begin
        logger.debug("filtering env by prefix '#{prefix}'")
        env.select { |k,v| k.start_with?(prefix) }

      rescue StandardError => e
        raise e
      end
    end
  end
end
