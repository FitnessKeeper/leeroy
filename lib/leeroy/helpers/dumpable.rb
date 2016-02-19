require 'multi_json'

require 'leeroy/types/mash'
require 'leeroy/helpers/logging'

module Leeroy
  module Helpers
    module Dumpable

      attr_accessor :dump_properties

      def dump
        begin
          dump_mash = Leeroy::Types::Mash.new

          dump_properties = self.dump_properties

          if dump_properties.length == 0
            logger.warn "dumping an object with no dump_properties set, this is unlikely to end well"
          end

          self.dump_properties.each do |property|
            if self.respond_to?(property.to_sym)
              raw = self.fetch(property.to_s)

              cooked = raw.respond_to?(:dumper) ? raw.dumper : raw

              dump_mash.store(property.to_s, cooked)
            end
          end

          logger.debug "dump_mash: #{dump_mash.inspect}"

          MultiJson.dump(dump_mash.to_hash)

        rescue StandardError => e
          raise e
        end
      end

      def dumper
        self.to_s
      end

    end
  end
end
