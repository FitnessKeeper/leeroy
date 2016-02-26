require 'leeroy'
require 'leeroy/types/dash'
require 'leeroy/types/mash'
require 'leeroy/types/phase'
require 'leeroy/types/userdata'
require 'leeroy/helpers/dumpable'
require 'leeroy/helpers/logging'

module Leeroy
  module Types
    class Instance < Leeroy::Types::Dash

      include Leeroy::Helpers::Dumpable
      include Leeroy::Helpers::Logging

      property :phase, required: true, coerce: Leeroy::Types::Phase
      property :aws_params

      # AWS-specific params
      property :iam_instance_profile, required: true
      property :image_id, required: true
      property :instance_type, required: true
      property :key_name, required: true
      property :max_count, required: true
      property :min_count, required: true
      property :security_group_ids, required: true
      property :subnet_id, required: true
      property :user_data, default: '', coerce: Leeroy::Types::UserData

      def initialize(*args, &block)
        self.aws_params = [
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

        self.dump_properties = self.aws_params

        super
      end

      def run_params
        begin
          params_hash = Leeroy::Types::Mash.new

          self.aws_params.each {|param| params_hash.store(param.to_s, self.fetch(param.to_s))}

          # UserData is special!

          params_hash.store('user_data', self.fetch('user_data').encoded_for_ec2)

          params_hash

        rescue StandardError => e
          raise e
        end
      end

    end
  end
end
