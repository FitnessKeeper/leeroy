require 'yell'

require 'leeroy/helpers/logging'
require 'leeroy/types/dash'

module Leeroy
  module Types
    class StateData < Leeroy::Types::Dash
      include Leeroy::Helpers::Logging

      property :message, coerce: String
      property :instanceid
      property :imageid
      property :semaphore
      property :sgid
      property :subnetid
      property :vpcid

    end
  end
end
