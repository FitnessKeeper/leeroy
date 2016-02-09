require 'yell'

require 'leeroy/types/dash'

module Leeroy
  module Types
    Yell.new :stderr, :name => 'Leeroy::Types::StateMetadata'

    class StateMetadata < Leeroy::Types::Dash
      include Yell::Loggable

      property :current, required: true
      property :previous, default: nil

    end
  end
end
