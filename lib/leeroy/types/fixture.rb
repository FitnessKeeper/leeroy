require 'leeroy/types/enum'

module Leeroy
  module Types
    class Fixture < Leeroy::Types::Enum

      new :POSTGRES
      new :CLOUDANT, lambda {|x| raise "FIXME not implemented yet"}
      new :S3, lambda {|x| raise "FIXME not implemented yet"}

    end
  end
end
