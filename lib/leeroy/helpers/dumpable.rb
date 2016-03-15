require 'multi_json'

require 'leeroy/types/mash'
require 'leeroy/helpers/logging'

module Leeroy
  module Helpers
    module Dumpable

      attr_accessor :dump_properties

      def dump
        begin
          logger.debug "beginning dump"

          dump_mash = Leeroy::Types::Mash.new

          dump_properties = self.dump_properties
          logger.debug "dump_properties: #{dump_properties.inspect}"

          if dump_properties.length == 0
            logger.warn "dumping an object with no dump_properties set, this is unlikely to end well"
          end

          self.dump_properties.each do |property|
            logger.debug "dumping property '#{property.to_s}'"
            if self.respond_to?(property.to_sym)
              begin
                raw = self.fetch(property.to_s)

                cooked = raw.respond_to?(:dumper) ? raw.dumper : raw

                dump_mash.store(property.to_s, cooked)

              rescue KeyError => e
                logger.debug e.message
              end
            end
          end

          logger.debug "dump_mash: #{dump_mash.inspect}"

          MultiJson.dump(dump_mash.to_hash)

        rescue StandardError => e
          raise e
        end
      end

      def dumper
        begin
          dump_hash = {}

          self.dump_properties.each do |property|
            the_prop = self.send(property.to_sym)
            dump_hash[property] = the_prop.respond_to?(:dumper) ? the_prop.dumper : the_prop
          end

          dump_hash

        rescue StandardError => e
          raise e
        end
      end

    end
  end
end
