require 'leeroy/helpers'
require 'leeroy/helpers/env'
require 'rugged'


module Leeroy
  module Helpers
    module Git
      include Leeroy::Helpers

      #attr :packer_client
      def initialize(*args, &block)
        super(*args, &block)

        logger.debug "initializing Git helpers"
        logger.debug "Git helpers initialized"
      end
      #        dirname = File.basename(Dir.getwd)
      #        @repo = Rugged::Repository.new('path/to/my/repository')
      def getShortCommitHash(pwd='.')
        begin

          commit_hash = getCommitHash(pwd)
          short_hash = commit_hash[0..6]

          logger.debug "Short Git Hash : #{commit_hash[0..6]}'"

          short_hash

        rescue RuntimeError => e
          logger.debug "failed with message: #{e.message}"
          raise e
        rescue StandardError => e
          raise e
        end
      end

      def getCommitHash(cwd='.')
        begin
          Dir.chdir(cwd) do
            repo = Rugged::Repository.new(cwd)
            logger.debug "Loaded Git Repo:'#{cwd}'"
            commit_hash = repo.last_commit.oid

            logger.debug "Git Commit Hash : #{commit_hash}'"

            commit_hash
          end

        rescue RuntimeError => e
          logger.debug "failed with message: #{e.message}"
          raise e
        rescue StandardError => e
          raise e
        end
      end
    end
  end
end
