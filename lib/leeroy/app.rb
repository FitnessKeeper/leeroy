#!/usr/bin/env ruby

require 'ap'
require 'gli'

require 'leeroy'
require 'leeroy/task/image'
require 'leeroy/task/instantiate'
require 'leeroy/task/terminate'
require 'leeroy/task/sleep'
require 'leeroy/task/stub'

include GLI::App

module Leeroy
  module App

    # constants
    VALID_PHASE = ['gold_master','application']

    program_desc 'Automate tasks with Jenkins'

    # global options
    desc "Perform the requested task (pass '--no-op' for testing)."
    switch [:op], :default_value => true

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

    desc "Instantiates an EC2 instance for imaging."
    command :instantiate do |c|

      valid_phase = VALID_PHASE
      c.desc "Phase of deploy process for which to deploy (must be one of #{valid_phase.sort})."
      c.flag [:p, :phase], :must_match => valid_phase

      c.action do |global_options,options,args|
        # validate input
        if options[:phase].nil?
          help_now! "You must pass an argument for '--phase'."
        end

        task = Leeroy::Task::Instantiate.new(global_options: global_options, options: options, args: args)
        task.perform
      end
    end

    desc "Terminates an EC2 instance."
    command :terminate do |c|

      c.desc "Instance ID (or IDs as comma-delimited strings) to terminate (reads from state if none provided)."
      c.flag [:i, :instance], :type => Array

      c.action do |global_options,options,args|
        task = Leeroy::Task::Terminate.new(global_options: global_options, options: options, args: args)
        task.perform
      end
    end

    desc "Creates an image from a running EC2 instance."
    command :image do |c|

      valid_phase = VALID_PHASE
      c.desc "Phase of deploy process for which to deploy (must be one of #{valid_phase.sort})."
      c.flag [:p, :phase]

      c.desc "Image index (optional, will be calculated if not provided)."
      c.flag [:i, :index]

      c.action do |global_options,options,args|
        # validate input
        unless options[:phase].nil? or valid_phase.include?(options[:phase])
          help_now! "You must pass an argument for '--phase'."
        end

        # index must be nil or must look like a positive integer
        begin
          unless options[:index].nil? or options[:index].to_i > 0
            help_now! "The argument for '--index' must be a positive integer."
          end

        rescue NoMethodError => e
          help_now! "The argument for '--index' must be a positive integer."
        end

        task = Leeroy::Task::Image.new(global_options: global_options, options: options, args: args)
        task.perform
      end
    end

    desc "Sleeps for some number of seconds."
    command :sleep do |c|
      c.desc "Number of seconds to sleep."
      c.flag [:i, :interval], :default_value => 2
      c.action do |global_options,options,args|
        Leeroy::Task::Sleep.new(global_options: global_options, options: options, args: args).perform
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
