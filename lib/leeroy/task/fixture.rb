require 'leeroy'
require 'leeroy/task'
require 'leeroy/types/fixture'
require 'leeroy/helpers/aws'
require 'leeroy/helpers/env'
require 'leeroy/helpers/template'

module Leeroy
  module Task
    class Fixture < Leeroy::Task::Base
      include Leeroy::Helpers::AWS
      include Leeroy::Helpers::Env
      include Leeroy::Helpers::Template

      def perform(args = self.args, options = self.options, global_options = self.global_options)
        begin
          super(args, options, global_options)

          state = self.state

          # what kind of fixture are we processing?
          fixture = Leeroy::Types::Fixture.from_s(options[:fixture])

          logger.debug "processing a '#{fixture}' fixture"

          # get branch from CLI, or env, or state if available
          branch = options[:branch]

          if branch.nil?
            branch = checkEnv("LEEROY_BRANCH", lambda { |x| true })
          end

          if branch.nil?
            branch = state.branch
          end

          if branch.nil?
            raise RuntimeError.new("Unable to determine branch from CLI, environment, or state.")
          else
            state.branch = branch
          end

          # process it
          processed = self.send(fixture.value.to_sym, state, options, global_options)

          logger.debug "processed: #{processed.inspect}"

          dump_state

          logger.debug "done performing for #{self.class}"

        rescue StandardError => e
          raise e
        end
      end

      private

      def postgres(state, options, global_options)
        begin
          # extract params from options
          header = options[:header]

          # is this a dry run or the real thing?
          dry_run = global_options[:op] ? false : true

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

          logger.debug "DB template will be stored in '#{dumpdst}'"

          dumpobj = genSemaphore(dumpdst, dump)

          if dry_run
            logger.info "dry run, not storing DB template"
          else
            setSemaphore(dumpobj)
          end

        rescue StandardError => e
          raise e
        end
      end

      def flyway(state, options, global_options)
        begin
          # is this a dry run or the real thing?
          dry_run = global_options[:op] ? false : true

          branch = state.branch



        rescue StandardError => e
          raise e
        end
      end

    end
  end
end
