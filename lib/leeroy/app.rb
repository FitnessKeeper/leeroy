#!/usr/bin/env rubhh

require 'ap'
require 'gli'

require 'leeroy'
require 'leeroy/task/stub'

include GLI::App

module Leeroy
  module App

    program_desc 'Automate tasks with Jenkins'

    # global options
    desc 'Use in a pipeline (read state from stdin)'
    switch [:p, :pipe]

    desc 'Displays the version of leeroy and exits.'
    command :version do |c|
      c.action do |global_options,options,args|
        printf("leeroy %s\n", Leeroy::VERSION)
      end
    end

    desc "Displays leeroy's environment settings."
    command :env do |c|
      c.action do |global_options,options,args|
        ap Leeroy::Env.new
      end
    end

    desc "Runs the stub task."
    command :stub do |c|
      c.desc "Amount by which to increment the stub value"
      c.flag [:i, :increment], :default_value => 1
      c.action do |global_options,options,args|
        task = Leeroy::Task::Stub.new(global_options: global_options, options: options, args: args)
        task.perform
      end
    end

    exit run(ARGV)
  end
end
