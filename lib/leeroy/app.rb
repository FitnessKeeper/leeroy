#!/usr/bin/env rubhh

require 'ap'
require 'gli'

require 'leeroy'
require 'leeroy/task/getstate'

include GLI::App

module Leeroy
  module App

    program_desc 'Automate tasks with Jenkins'

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

    command :get do |c|
      c.desc "Gets one or more values from leeroy's state store."
      c.action do |global_options,options,args|
        begin
          gs = Leeroy::Task::GetState.new(:params => {:args => args})
          ap gs.perform()
        rescue StandardError => e
          raise e
        end
      end
    end

    exit run(ARGV)
  end
end
