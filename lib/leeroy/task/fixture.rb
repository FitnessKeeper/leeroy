require 'leeroy'
require 'leeroy/task'
require 'leeroy/types/fixture'
require 'leeroy/helpers/aws'
require 'leeroy/helpers/template'

module Leeroy
  module Task
    class Fixture < Leeroy::Task::Base
      include Leeroy::Helpers::AWS
      include Leeroy::Helpers::Template

      def perform(args = self.args, options = self.options, global_options = self.global_options)
        begin
          super(args, options, global_options)

          state = self.state

          # what kind of fixture are we processing?
          fixture = Leeroy::Types::Fixture.from_s(options[:fixture])

          logger.debug "processing a '#{fixture}' fixture"

          # process it
          processed = self.send(fixture.value.to_sym, state, options)

          logger.debug "processed: #{processed.inspect}"

          dump_state

          logger.debug "done performing for #{self.class}"

        rescue StandardError => e
          raise e
        end
      end

      private

      def postgres(state, options)
        begin
          # extract params from options
          header = options[:header]

          # get the DB template from S3
          dumpsrc = buildS3ObjectName(checkEnv('LEEROY_DB_TEMPLATE'), 'sql')

          logger.debug "retrieving DB template from '#{dumpsrc}'"

          dumpobj = genSemaphore(dumpsrc)

          # is the template in S3?
          raise "DB template not available in S3" unless checkSemaphore(dumpobj)

          # start building the DB dump
          dump = ''
          dumptemplate = getSemaphore(dumpobj)

          unless header.nil?
            # render the DB header
            headertemplate = File.join(checkEnv('LEEROY_PROVISIONING_TEMPLATE_PREFIX'), header)
            logger.debug "rendering header template '#{headertemplate}'"
            dump.concat(renderTemplate(headertemplate))
          end

          # render the DB template
          dump.concat(renderTemplate(dumptemplate))

          # store the rendered template in S3
          dumpdst = buildS3ObjectName(checkEnv('LEEROY_DB_NAME') + '.sql', 'sql')

          logger.debug "storing DB template in '#{dumpdst}'"

          dumpobj = genSemaphore(dumpdst, dump)

          setSemaphore(dumpobj)

        rescue StandardError => e
          raise e
        end
      end

    end
  end
end
