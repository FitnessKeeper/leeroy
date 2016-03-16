require 'yell'

require 'leeroy/helpers/dumpable'
require 'leeroy/helpers/logging'
require 'leeroy/types/dash'
require 'leeroy/types/mash'
require 'leeroy/types/phase'
require 'leeroy/types/semaphore'

module Leeroy
  module Types
    class StateData < Leeroy::Types::Dash
      include Leeroy::Helpers::Logging
      include Leeroy::Helpers::Dumpable

      property :message, coerce: String
      property :app_name, coerce: String
      property :instanceid, coerce: String
      property :imageid, coerce: String
      property :phase, coerce: lambda {|x| Leeroy::Types::Phase.from_s(x.to_s)}
      property :semaphore, coerce: Leeroy::Types::Semaphore
      property :sgid, coerce: String
      property :subnetid, coerce: String
      property :vpcid, coerce: String

      def initialize(*args, &block)
        super

        self.dump_properties = [
          :app_name,
          :imageid,
          :instanceid,
          :message,
          :phase,
          :semaphore,
          :sgid,
          :subnetid,
          :vpcid,
        ]
      end

    end
  end
end
