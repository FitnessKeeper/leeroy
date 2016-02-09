require 'chronic'
require 'yell'

require 'leeroy/types/dash'

module Leeroy
  module Types
    Yell.new :stderr, :name => 'Leeroy::Types::StateMetadata'

    class StateMetadata < Leeroy::Types::Dash
      include Yell::Loggable

      property :task, required: true
      property :previous, default: nil
      property :created, coerce: Proc.new { |t| Chronic.parse(t) }, default: 'now'

    end
  end
end
