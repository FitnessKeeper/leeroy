require 'aws-sdk'

require 'leeroy/helpers'

module Leeroy
  module Helpers
    class AWS < Leeroy::Helpers::Base

      @env = Leeroy::Env.new

      # set default region if not set
      if @env.AWS_REGION.nil?
        Aws.config.update({
          region: 'us-east-1'
        })
      end

      def self.S3
        Aws::S3::Client.new
      end
    end
  end
end
