require 'base64'

require 'leeroy'
require 'leeroy/types/dash'
require 'leeroy/types/mash'
require 'leeroy/helpers/logging'

module Leeroy
  module Types
    class Instance < Leeroy::Types::Dash
      include Leeroy::Helpers::Logging

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

      def run_params
        begin
          run_params = Leeroy::Types::Mash.new

          [
            :iam_instance_profile,
            :image_id,
            :instance_type,
            :key_name,
            :max_count,
            :min_count,
            :security_group_ids,
            :subnet_id,
          ].map {|key| run_params.store(key.to_s, self.fetch(key))}

          # user_data file depends on phase
          user_data = self.user_data
          run_params.user_data = Base64.urlsafe_encode64(user_data.extract)

          logger.debug "run_params: #{run_params.inspect}"

          run_params

        rescue StandardError => e
          raise e
        end
      end

    end
  end
end
