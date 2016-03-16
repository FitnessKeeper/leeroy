require 'leeroy/helpers'

module Leeroy
  module Helpers
    module Template
      include Leeroy::Helpers

      def renderTemplate(template, b = binding)
        begin
          logger.debug "processing template '#{template}'"

          # is the template a file?
          begin
            template_str = File.read(template)

          rescue Errno::ENOENT => e
            logger.debug e.message
            template_str = template
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
