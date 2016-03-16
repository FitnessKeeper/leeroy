require 'leeroy/helpers'

module Leeroy
  module Helpers
    module Template
      include Leeroy::Helpers

      def renderTemplate(template, b = binding)
        begin
          # is the template a file?
          begin
            template_str = File.read(template)
            logger.debug "reading template from '#{template}'"

          rescue SystemCallError => e
            logger.debug e.message
            template_str = template
            logger.debug "reading template from provided string"
          end

          # run the ERB renderer in a separate thread, restricted
          # http://www.stuartellis.eu/articles/erb/
          ERB.new(template_str, 0).result(b)

        rescue StandardError => e
          raise e
        end
      end

    end
  end
end
