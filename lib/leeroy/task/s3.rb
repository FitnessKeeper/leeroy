require 'leeroy'
require 'leeroy/task'
require 'leeroy/helpers/aws'

module Leeroy
  module Task
    class S3 < Leeroy::Task::Base
      include Leeroy::Helpers::AWS

    end
  end
end
