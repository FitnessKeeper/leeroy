#!/usr/bin/env ruby

require 'gli'

require 'leeroy'
require 'leeroy/task/fixture'
require 'leeroy/task/image'
require 'leeroy/task/instantiate'
require 'leeroy/task/terminate'
require 'leeroy/task/sleep'
require 'leeroy/task/packer'
require 'leeroy/task/stub'
require 'leeroy/types/fixture'
require 'leeroy/types/phase'

include GLI::App

module Leeroy
  module App

    # constants
    VALID_PHASE = Leeroy::Types::Phase.to_a.collect {|x| x.value}
    VALID_FIXTURE = Leeroy::Types::Fixture.to_a.collect {|x| x.value}

    program_desc 'Automate tasks with Jenkins. When passing arguments, order is, CLI argument, then ENV[LEEROY_VAR]'

    # global options
    desc "Perform the requested task (pass '--no-op' for testing)."
    switch [:op], :default_value => true

    desc "Control reading of state from stdin (pass '--no-stdin' to force disable)."
    switch [:stdin], :default_value => true

    # commands
    desc 'Displays the version of leeroy and exits.'
    command :version do |c|
      c.action do |global_options,options,args|
        printf("leeroy %s\n", Leeroy::VERSION)
      end
    end

    desc "Displays leeroy's environment settings."
    command :env do |c|
      c.desc "Use default environment settings instead of reading from shell environment."
      c.switch :default, :d

      c.desc "Format environment settings for use in .profile."
      c.switch :profile, :p

      c.action do |global_options,options,args|
        puts Leeroy::Env.new(options).to_s
      end
    end

    desc "Instantiates an EC2 instance for imaging."
    command :instantiate do |c|

      valid_phase = VALID_PHASE
      c.desc "Phase of deploy process for which to deploy (must be one of #{valid_phase.sort})."
      c.flag [:p, :phase], :must_match => valid_phase

      c.action do |global_options,options,args|
        # validate input
        unless options[:phase].nil? or valid_phase.include?(options[:phase])
          help_now! "Valid arguments for '--phase' are: #{valid_phase.join(',')}."
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

      c.desc "Instance ID from which to image (optional, will be extracted from state if not provided)."
      c.flag [:i, :instance]

      c.desc "Image index (optional, will be calculated if not provided)."
      c.flag [:n, :index]

      c.action do |global_options,options,args|
        # validate input
        unless options[:phase].nil? or valid_phase.include?(options[:phase])
          help_now! "Valid arguments for '--phase' are: #{valid_phase.join(',')}."
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
##
    desc "Creates an image from a Packer template."
    command :packer do |c|

      valid_phase = VALID_PHASE
      c.desc "Phase of deploy process for which to deploy (must be one of #{valid_phase.sort})."
      c.flag [:p, :phase]

      c.desc "Source AMI - Order of presence is state, CLI argument, then ENV[LEEROY_AWS_LINUX_AMI]"
      c.flag [:i, :imageid]

      c.desc "LEEROY_APP_NAME"
      c.flag [:n, :name]

      #c.desc "LEEROY_PACKER_TEMPLATE_PREFIX"
      #c.flag []

      c.action do |global_options,options,args|
      # validate input
        unless options[:phase].nil? or valid_phase.include?(options[:phase])
        help_now! "Valid arguments for '--phase' are: #{valid_phase.join(',')}."
        end

        # index must be nil or must look like a positive integer
        #begin
        #  unless options[:index].nil? or options[:index].to_i > 0
        #    help_now! "The argument for '--index' must be a positive integer."
        #  end

        #rescue NoMethodError => e
        #  help_now! "The argument for '--index' must be a positive integer."
        #end
        #task = Leeroy::Task::Packer.new(global_options: global_options, options: options, args: args)
        task = Leeroy::Task::Packer.new(global_options: global_options, options: options, args: args)
        task.perform
      end
    end
##

    desc "Creates a fixture for a staging environment."
    command :fixture do |c|

      valid_fixture = VALID_FIXTURE
      c.desc "Phase of deploy process for which to deploy (must be one of #{valid_fixture})."
      c.flag [:f, :fixture], :must_match => valid_fixture

      c.desc "Header template to be rendered before fixture template."
      c.flag [:h, :header], :default_value => nil

      c.action do |global_options,options,args|
        # validate input
        unless options[:fixture].nil? or valid_fixture.include?(options[:fixture])
          help_now! "Valid arguments for '--fixture' are: #{valid_fixture.join(',')}."
        end

        task = Leeroy::Task::Fixture.new(global_options: global_options, options: options, args: args)
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
