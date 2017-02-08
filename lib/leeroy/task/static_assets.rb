require 'leeroy'
require 'leeroy/task'
require 'leeroy/helpers/aws'
require 'leeroy/helpers/git'

module Leeroy
  module Task
    class StaticAssets < Leeroy::Task::Base
      include Leeroy::Helpers::AWS
      include Leeroy::Helpers::Git

      def perform(args = self.args, options = self.options, global_options = self.global_options)
        begin
          super(args, options, global_options)

          # Does static assets really need state?
          phase = Leeroy::Types::Phase.resolve(self.state.fetch('phase'), options[:phase])
          logger.debug "phase: #{phase}"
          # update phase in state
          self.state.phase = phase


           git_hash = getShortCommitHash

#          packer_params = _getPackerParams
#          packer_vars = Leeroy::Types::Packer.new(packer_params)

          # Sending app_name to state
#          self.state.app_name = packer_vars.app_name

          # cwd is the fille filename where the packer template lives
#          cwd = File.join(packer_vars.packer_template_prefix, self.state.app_name)

#          validation = validatePacker(cwd, { :vars => packer_vars })

#          build = buildPacker(cwd,{ :vars => packer_vars } )
#          build.artifacts.each do | item |
#            self.state.message = item.string
#            artifact = item.id.split(':')
#            self.state.imageid = artifact[1]
#          end

          #logger.debug "#{build.stdout}"
          logger.debug "Packer Artifact Created : #{state.imageid}"

          dump_state

          logger.debug "done performing for #{self.class}"

        rescue StandardError => e
          logger.debug e.message
          raise e
        end
      end
      private
      def _getStaticAssetParams(state = self.state, env = self.env, options = self.options)
        begin
          logger.debug "generating StaticAsset params"
          sa_params = Leeroy::Types::Mash.new
          #static_asssets_path,
          #static_asssets_s3_prefix
          #static_asssets_s3_bucket

          if self.state.static_asssets_path?
            static_asssets_path = self.state.static_asssets_path
          elsif options[:static_asssets_path].nil?
            static_asssets_path = checkEnv('LEEROY_STATIC_ASSETS')
          else
            static_asssets_path = options[:static_asssets_path]
          end
          sa_params.static_asssets_path = static_asssets_path

          if self.state.static_asssets_s3_bucket?
            static_asssets_s3_bucket = self.state.static_asssets_s3_bucket
          elsif options[:static_asssets_s3_bucket].nil?
            static_asssets_s3_bucket = checkEnv('LEEROY_STATIC_ASSETS_S3_BUCKET')
          else
            static_asssets_s3_bucket = options[:static_asssets_s3_bucket]
          end
          sa_params.static_asssets_s3_bucket = static_asssets_s3_bucket

          if self.state.static_asssets_s3_prefix?
            static_asssets_s3_prefix = self.state.static_asssets_s3_prefix
          elsif options[:static_asssets_s3_prefix].nil?
            static_asssets_s3_prefix = checkEnv('LEEROY_STATIC_ASSETS_S3_PREFIX')
          else
            static_asssets_s3_prefix = options[:static_asssets_s3_prefix]
          end
          sa_params.static_asssets_s3_prefix = static_asssets_s3_prefix

          if self.state.aws_region?
            aws_region = self.state.aws_region
          else
            aws_region = ENV['AWS_DEFAULT_REGION'] || ENV['AWS_REGION']
          end
          sa_params.aws_region = aws_region

          sa_params
        rescue StandardError => e
          raise e
        end
      end
    end
  end
end
