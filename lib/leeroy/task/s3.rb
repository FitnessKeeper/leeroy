require 'leeroy'
require 'leeroy/task'
require 'leeroy/helpers/aws'

module Leeroy
  module Task
    class S3 < Leeroy::Task::Base
      include Leeroy::Helpers::AWS

      # constants
      # FIXME y u no hash?????
      SECRETS_PREFIX = 'secrets'
      JENKINS_PREFIX = 'jenkins'
      BUILDS_PREFIX = 'builds'
      LOGS_PREFIX = 'logs'
      SEMAPHORES_PREFIX = 'semaphores'
      TESTS_PREFIX = 'tests'

      private

      def _build_s3_prefix(key, prefix, bucket)
      end

    end
  end
end
