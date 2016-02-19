require 'base64'
require 'zlib'

require 'leeroy/helpers/dumpable'
require 'leeroy/types/dash'

module Leeroy
  module Types
    class PackedString < String
      include Leeroy::Helpers::Dumpable

      def pack(input = self.to_s)
        Base64.urlsafe_encode64(Zlib::Deflate.deflate(input))
      end

      def unpack(input = self.to_s)
        Zlib::Inflate.inflate(Base64.urlsafe_decode64(input))
      end

      alias_method :dumper, :pack
      alias_method :extract, :unpack

    end
  end
end
