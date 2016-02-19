require 'yell'

require 'leeroy/helpers/dumpable'
require 'leeroy/helpers/logging'
require 'leeroy/types/dash'
require 'leeroy/types/mash'
require 'leeroy/types/semaphore'

module Leeroy
  module Types
    class StateData < Leeroy::Types::Dash
      include Leeroy::Helpers::Logging
      include Leeroy::Helpers::Dumpable

      property :message, coerce: String
      property :instanceid
      property :imageid
      property :semaphore, coerce: Leeroy::Types::Semaphore
      property :sgid
      property :subnetid
      property :vpcid

      def initialize(*args, &block)
        super

        self.dump_properties = [
          :message,
          :instanceid,
          :imageid,
          :semaphore,
          :sgid,
          :subnetid,
          :vpcid,
        ]
      end

    end
  end
end
