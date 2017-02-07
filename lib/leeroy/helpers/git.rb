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
      def getShortCommitHash(pwd='/Users/alaric/git/leeroy')
        begin
          repo = Rugged::Repository.new(pwd)
          logger.debug "Loaded Git Repo:'#{pwd}'"
          commit_hash = repo.last_commit.oid
          short_hash = commit_hash[0..6]

          logger.debug "Long Git Hash : #{commit_hash}'"
          logger.debug "Short Git Hash : #{commit_hash[0..6]}'"

          short_hash

        rescue RuntimeError => e
          logger.debug "failed with message: #{e.message}"
          raise e
        rescue StandardError => e
          raise e
        end
      end

##
      # cwd in the below code inticates the command working directory
      # which is used to change dir's into the directory where main.json is
      # so that relitive paths used in the packer template expand correctly
###
    end
  end
end
