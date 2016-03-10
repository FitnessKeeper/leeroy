require 'leeroy/helpers'

module Leeroy
  module Helpers
    module Template
      include Leeroy::Helpers

      def renderTemplate(template, b = binding)
        begin
          logger.debug "processing template '#{template}'"

          # run the ERB renderer in a separate thread, restricted
          # http://www.stuartellis.eu/articles/erb/
          ERB.new(File.read(template), 0).result(binding)

        rescue StandardError => e
          raise e
        end
      end

    end
  end
end
