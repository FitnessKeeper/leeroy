require 'leeroy/types/enum'

module Leeroy
  module Types
    class Fixture < Leeroy::Types::Enum

      new :POSTGRES
      new :FLYWAY
      new :CLOUDANT, 'FIXME Cloudant not implemented yet'
      new :S3, 'FIXME S3 not implemented yet'

    end
  end
end
