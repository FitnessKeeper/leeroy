require 'leeroy/types/packedstring'
require 'leeroy/types/dash'

module Leeroy
  module Types
    class Semaphore < Leeroy::Types::Dash

      property :bucket
      property :object
      property :payload, coerce: Leeroy::Types::PackedString

    end
  end
end
