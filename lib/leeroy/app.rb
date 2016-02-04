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

    command :version do |c|
      c.desc 'Displays the version of leeroy and exits.'
      c.action do |global_options,options,args|
        printf("leeroy %s\n", Leeroy::VERSION)
      end
    end

    command :env do |c|
      c.desc "Displays leeroy's environment settings."
      c.action do |global_options,options,args|
        ap Leeroy::Env.new
      end
    end

    command :stub do |c|
      c.desc "Runs the stub task."
      c.action do |global_options,options,args|
        task = Leeroy::Task::Stub.new(global_options: global_options, options: options, args: args)
        task.perform
      end
    end

    exit run(ARGV)
  end
end
