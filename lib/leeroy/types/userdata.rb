require 'base64'

require 'leeroy/types/packedstring'

module Leeroy
  module Types
    class UserData < Leeroy::Types::PackedString
      def encoded_for_ec2(input = self.to_s)
        Base64.urlsafe_encode64(input)
      end
    end
  end
end
