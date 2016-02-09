require 'yell'

require 'leeroy/types/dash'

module Leeroy
  module Types
    Yell.new :stderr, :name => 'Leeroy::Types::StateData'

    class StateData < Leeroy::Types::Dash
      include Yell::Loggable

      property :message, coerce: String
      property :instanceid
      property :imageid
      property :sgid
      property :subnetid
      property :vpcid

    end
  end
end
