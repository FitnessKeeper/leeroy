require 'leeroy'
require 'leeroy/task'
require 'leeroy/helpers/aws'
require 'leeroy/helpers/inventory'
require 'packer'
#require 'leeroy/helpers/polling'
#require 'leeroy/helpers/template'

# input
# pass in path to packer template - ex rk-bastion/main.json
# LEEROY_APP_NAME=rk-bastion
# LEEROY_AWS_LINUX_AMI=ami-c481fad3
# LEEROY_BUILD_INSTANCE_TYPE=m3.medium
# AWS_REGION=us-east-1

# Output region and AMI


module Leeroy
  module Task
    class Packer < Leeroy::Task::Base
      include Leeroy::Helpers::AWS
      include Leeroy::Helpers::Inventory

      def initialize(*args, &block)
        super
        @client = ::Packer::Client.new
      end

      def perform(args = self.args, options = self.options, global_options = self.global_options)
        begin
          super(args, options, global_options)

          phase = Leeroy::Types::Phase.resolve(self.state.fetch('phase'), options[:phase])
          logger.debug "phase: #{phase}"
          self.state.phase = phase

          begin
            # we should probably check that this isn't empty
            #packer.perform({},{ :phase => 'gold_master', :template => '/Users/alaric/git/packer-rk-apps/rk-bastion/main.json' })
            # LEEROY_APP_NAME
            # We will build the path to the template with LEEROY_PACKER_TEMPLATE_PREFIX LEEROY_APP_NAME and assume the template uses main.json
            # Also, lets *pass in* the --phase=arg into the packer template itself, and let puppet, or whatever handle

            # { :vars => { :aws_linux_ami=>'ami-c481fad3', :app_name=>'rk-bastion', :aws_region =>'us-east-1'}
            # LEEROY_APP_NAME LEEROY_AWS_LINUX_AMI AWS_REGION

            packer_vars = {
              :app_name      => checkEnv('LEEROY_APP_NAME'),
              :aws_linux_ami => checkEnv('LEEROY_AWS_LINUX_AMI'),
              :aws_region    => ENV['AWS_REGION']
            }
            cwd = File.join(checkEnv('LEEROY_PACKER_TEMPLATE_PREFIX'), checkEnv('LEEROY_APP_NAME'))
            _validatePacker(cwd, { :vars => packer_vars })

            Dir.chdir(cwd) do
              foo = @client.build(File.join(cwd, "main.json"), { :vars => packer_vars } )
              logger.debug "#{foo}"
            end

          rescue SystemCallError => e
            logger.debug e.message
            raise e
          end

         # client.validate('/Users/alaric/git/packer-rk-apps/rk-bastion/main.json').valid?



          dump_state

          logger.debug "done performing for #{self.class}"

        rescue StandardError => e
          raise e
        end
      end

      private
      def _validatePacker(cwd, vars = {})
        begin
          Dir.chdir(cwd) do
            packer_ver = @client.version.version
            logger.debug "Loading Packer using version :'#{packer_ver}'"

            template = File.join(cwd, "main.json")
            logger.debug "Loading Packer Template :'#{template}'"

            logger.debug "Validating Packer Template syntax :'#{template}'"
            unless @client.validate(template, {:syntax_only => true }).valid?
              raise "Packer Template :'#{template}' has invalid syntax"
            end

            logger.debug "Validating Packer Template with vars :'#{template}'"
            #unless @client.validate( template ,{ :vars => { :aws_linux_ami=>'ami-c481fad3', :app_name=>'rk-bastion', :aws_region =>'us-east-1'}}).valid?
            unless @client.validate( template , vars ).valid?
              raise "Packer Template :'#{template}' is invalid"
            end
          end
        rescue StandardError => e
          raise e
        end



      end
    end
  end
end
