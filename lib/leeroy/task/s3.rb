require 'leeroy'
require 'leeroy/task'
require 'leeroy/helpers/aws'

module Leeroy
  module Task
    class S3 < Leeroy::Task::Base
      include Leeroy::Helpers::AWS

      def initialize(*)
        super
        @s3 = initialize_s3
      end
    end
  end
end
