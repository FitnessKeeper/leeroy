require 'base64'

require 'leeroy'
require 'leeroy/types/runnable'
require 'leeroy/types/packedstring'
require 'leeroy/helpers/logging'

module Leeroy
  module Types
    class Instance < Leeroy::Types::Runnable

      property :phase, required: true

      # AWS-specific params
      property :iam_instance_profile, required: true
      property :image_id, required: true
      property :instance_type, required: true
      property :key_name, required: true
      property :max_count, required: true
      property :min_count, required: true
      property :security_group_ids, required: true
      property :subnet_id, required: true
      property :user_data, default: '', coerce: Leeroy::Types::PackedString

      def initialize(*args, &block)
        super(*args, &block)

        self.params = [
          :iam_instance_profile,
          :image_id,
          :instance_type,
          :key_name,
          :max_count,
          :min_count,
          :security_group_ids,
          :subnet_id,
          :user_data,
        ]

        self.retrievals = {
          :user_data => lambda {|x,y| Base64.urlsafe_encode64(x.fetch(y).extract)}
        }

        self.command = :run_instances
      end

    end
  end
end
