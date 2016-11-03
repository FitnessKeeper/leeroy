require 'aws-sdk'
require 'base64'
require 'packer'

require 'leeroy/helpers'
require 'leeroy/helpers/env'

module Leeroy
  module Helpers
    module Packer
      include Leeroy::Helpers

      attr :packer_client

      def initialize(*args, &block)
        super(*args, &block)

        logger.debug "initializing Packer helpers"

        @packer_client = ::Packer::Client.new

        logger.debug "Packer helpers initialized"
      end

      def validatePacker(cwd, vars = {})
        begin
          packer_ver = self.packer_client.version.version
          logger.debug "Loading Packer using version :'#{packer_ver}'"

          template = File.join(cwd, "main.json")
          logger.debug "Loading Packer Template :'#{template}'"

          logger.debug "Validating Packer Template syntax :'#{template}'"

          validate( cwd, template, {:syntax_only => true })
          validate( cwd, template , vars )

        rescue RuntimeError => e
          logger.debug "Packer Template '#{template}' failed with message: #{e.message}"
          raise e
        rescue StandardError => e
          raise e
        end
      end

      def validate(cwd, *args)
        begin
          Dir.chdir(cwd) do
            validated = self.packer_client.validate(*args)

            if validated.valid?
              validated
            else
              raise RuntimeError.new(validated.stdout)
            end
          end
        end
      end


### Build
      def buildPacker(cwd, vars = {})
        begin
          packer_ver = self.packer_client.version.version
          logger.debug "Building Packer using version :'#{packer_ver}'"

          template = File.join(cwd, "main.json")
          logger.debug "Loading Packer Template :'#{template}'"

          logger.debug "Building Packer Template :'#{template}'"

          build( cwd, template , vars )

        rescue RuntimeError => e
          logger.debug "Packer Build '#{template}' failed with message: #{e.message}"
          raise e
        rescue StandardError => e
          raise e
        end
      end

      def build(cwd, *args)
        begin
          Dir.chdir(cwd) do
            output =self.packer_client.build(*args)

            if output.errors.any?
              raise RuntimeError.new(output.errors)
            else
              output
            end
          end
        end
      end
###
    end
  end
end
