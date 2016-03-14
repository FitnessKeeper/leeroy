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
      :builds     => 'builds',
      :fixtures   => 'fixtures',
      :jenkins    => 'jenkins',
      :logs       => 'logs',
      :secrets    => 'secrets',
      :semaphores => 'semaphores',
      :sql        => 'fixtures/sql',
      :tests      => 'tests',
    }

    ENV_DEFAULTS = {
      'LEEROY_APP_NAME' => '<identifying string, e.g. "tomcat7">',
      'LEEROY_AWS_LINUX_AMI' => '<AMI ID to be used as base for gold master>',
      'LEEROY_BUILD_INSTANCE_TYPE' => '<EC2 instance type to be used for imaging>',
      'LEEROY_BUILD_PROFILE_NAME' => '<IAM instance profile name to be applied to imaging instances>',
      'LEEROY_BUILD_SECURITY_GROUP' => '<VPC security group name to be applied to imaging instances>',
      'LEEROY_BUILD_SSH_KEYPAIR' => '<SSH keypair name for access to imaging instances>',
      'LEEROY_BUILD_SUBNET' => '<VPC subnet name to be applied to imaging instances>',
      'LEEROY_BUILD_TARGET' => '<identifying string for application build, e.g. "webapi" or "stage20">',
      'LEEROY_BUILD_VPC' => '<VPC name in which imaging instances are created>',
      'LEEROY_GOLD_MASTER_IMAGE_PREFIX' => '<identifying string used to generate AMI names>',
      'LEEROY_GOLD_MASTER_NAME' => '<identifying string used to tag gold master instances during imaging>',
      'LEEROY_POLL_INTERVAL' => '<number of seconds to wait between polling for long-running AWS operations>',
      'LEEROY_POLL_TIMEOUT' => '<number of seconds to wait between giving up on long-running AWS operations>',
      'LEEROY_PROVISIONING_TEMPLATE_PREFIX' => '<path on local filesystem to directory containing provisioning templates>',
      'LEEROY_S3_BUCKET' => '<name of bucket used as datastore>',
      'LEEROY_USER_DATA_PREFIX' => '<path on local filesystem to directory containing user-data scripts>',
    }

    ENV_EXTRAS = {
      'ENVIRONMENT' => '<development or production>',
      'GLI_DEBUG' => '<true or false>',
      'AWS_REGION' => '<your AWS region>',
    }

    # attr_reader :default, :profile
    attr_reader :profile, :defaults

    def initialize(options = {}, env = ENV)
      begin
        logger.debug "initializing #{self.class}"
        logger.debug "options: #{options.inspect}"

        @defaults = options[:default]
        @profile = options[:profile]

        if self.defaults
          unfiltered = ENV_DEFAULTS
          extras = ENV_EXTRAS
        else
          unfiltered = env
          extras = {}
        end

        filtered = _filterEnv(unfiltered).merge(extras)
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

      if self.defaults
        formatstr = '# '.concat(formatstr)
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
