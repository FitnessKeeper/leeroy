require 'awesome_print'

require 'leeroy/env'
require 'leeroy/helpers'

module Leeroy
  module Helpers
    module Env
      include Leeroy::Helpers

      attr_reader :env

      def checkEnv(param, check = lambda { |x| ! x.nil? }, errmsg = "You must provide #{param} in the environment.", env = self.env)
        begin
          logger.debug "checking for '#{param}' in environment"

          # get param from env
          candidate = env.fetch(param, nil)
          logger.debug "candidate: #{candidate}"

          # check it against the check
          check_passed = check.call(candidate)
          logger.debug "check_passed: #{check_passed}"

          if check_passed
            candidate
          else
            raise errmsg
          end

        rescue NoMethodError => e
          logger.error "unable to read environment! env: #{env.inspect}"
          raise e

        rescue StandardError => e
          raise e
        end
      end

    end
  end
end
