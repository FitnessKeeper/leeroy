#!/usr/bin/env ruby

require 'gli'

require 'leeroy'

include GLI::App

module Leeroy::App

  program_desc 'Automate tasks with Jenkins'

  command :version do |c|
    c.desc 'Displays the version of leeroy and exits.'
    c.action do|global_options,options,args|
      printf("leeroy %s\n", Leeroy::VERSION)
    end
  end

  exit run(ARGV)
end
