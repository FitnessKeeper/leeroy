require 'aws-sdk'

require 'leeroy/helpers'
require 'leeroy/helpers/env'

module Leeroy
  module Helpers
    module AWS
      include Leeroy::Helpers

      attr :s3

      def initialize_s3
        Aws::S3::Client.new
      end
    end
  end
end
