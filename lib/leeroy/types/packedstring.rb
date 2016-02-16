require 'base64'
require 'zlib'

require 'leeroy/types/dash'

module Leeroy
  module Types
    class PackedString < String

      def initialize(*args)
        if args.length > 0
          super(Base64.urlsafe_encode64(Zlib::Deflate.deflate(*args)))
        else
          super
        end
      end

      def extract
        Zlib::Inflate.inflate(Base64.urlsafe_decode64(self.to_s))
      end

    end
  end
end
