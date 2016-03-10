require 'leeroy'
require 'leeroy/task'
require 'leeroy/helpers/aws'
require 'leeroy/helpers/polling'
require 'leeroy/helpers/template'

module Leeroy
  module Task
    class Instantiate < Leeroy::Task::Base
      include Leeroy::Helpers::AWS
      include Leeroy::Helpers::Polling
      include Leeroy::Helpers::Template

      def perform(args = self.args, options = self.options, global_options = self.global_options)
        begin
          super(args, options, global_options)

          phase = Leeroy::Types::Phase.new(self.state.fetch('phase', options[:phase]))
          self.state.phase = phase

          # resolve various AWS resources from human-readable inputs
          _resolveResources

          # create instance
          instance = Leeroy::Types::Instance.new(_genInstanceParams)
          resp = ec2Request(:run_instances, instance.run_params)
          instanceid = resp.instances[0].instance_id
          self.state.instanceid = instanceid

          # wait until instance is starting
          _prepInstanceCreationPolling
          poll(instanceid)

          # tag instance
          instance_name = phase == 'gold_master' ? getGoldMasterInstanceName : getApplicationInstanceName
          createTags({'Name' => instance_name})

          # write semaphore
          s3_object = buildS3ObjectName(instanceid, 'semaphores')
          payload = _readSemaphore(phase)
          semaphore = setSemaphore(genSemaphore(s3_object, payload))
          self.state.semaphore = semaphore

          # wait until instance is done provisioning
          _prepInstanceProvisionPolling
          poll(semaphore)

          dump_state

          logger.debug "done performing for #{self.class}"

        rescue StandardError => e
          raise e
        end
      end

      def initialize(*args, &block)
        super

      end

      private

      def _prepInstanceCreationPolling
        # poll to make sure instance is created
        self.poll_callback = lambda do |instanceid|
          begin
            run_params = { :instance_ids => [instanceid] }
            resp = ec2Request(:describe_instances, run_params)

          rescue Aws::EC2::Errors::InvalidInstanceIDNotFound => e
            logger.debug "instance #{instanceid} not found"
            nil
          rescue StandardError => e
            raise e
          end
        end

        self.poll_timeout = 30
        self.poll_interval = 2
      end

      def _prepInstanceProvisionPolling
        # poll until semaphore has been removed
        self.poll_callback = lambda {|s| checkSemaphore(s).nil?}
        self.poll_timeout = checkEnv('LEEROY_POLL_TIMEOUT').to_i
        self.poll_interval = checkEnv('LEEROY_POLL_INTERVAL').to_i
      end

      def _readSemaphore(phase)
        begin
          template = File.join(checkEnv('LEEROY_PROVISIONING_TEMPLATE_PREFIX'), "#{phase}.erb")
          renderTemplate(template, binding)

        rescue StandardError => e
          raise e
        end
      end

      def _resolveResources(state = self.state, env = self.env, ec2 = self.ec2, options = self.options)
        begin
          # resolve VPC ID
          if state.vpcid?
            vpcid = state.vpcid
          else
            vpcname = checkEnv('LEEROY_BUILD_VPC')
            vpcid = getVpcId(vpcname)
            state.vpcid = vpcid
          end

          # resolve security group
          if state.sgid?
            sgid = state.sgid
          else
            sgname = checkEnv('LEEROY_BUILD_SECURITY_GROUP')
            sgid = getSgId(sgname, vpcname, vpcid)
            state.sgid = sgid
          end

          # resolve subnet
          if state.subnetid?
            subnetid = state.subnetid
          else
            subnetname = checkEnv('LEEROY_BUILD_SUBNET')
            subnetid = getSubnetId(subnetname, vpcid)
            state.subnetid = subnetid
          end

        rescue StandardError => e
          raise e
        end
      end

      def _genInstanceParams(state = self.state, env = self.env, ec2 = self.ec2, options = self.options)
        begin
          logger.debug "generating params for creating an EC2 instance"

          # gather the necessary parameters
          instance_params = Leeroy::Types::Mash.new

          instance_params.security_group_ids = Array(state.sgid)
          instance_params.subnet_id = state.subnetid

          instance_params.key_name = checkEnv('LEEROY_BUILD_SSH_KEYPAIR')
          instance_params.instance_type = checkEnv('LEEROY_BUILD_INSTANCE_TYPE')

          instance_params.min_count = 1
          instance_params.max_count = 1

          instance_params.store('iam_instance_profile', {:name =>  checkEnv('LEEROY_BUILD_PROFILE_NAME')})

          # some parameters depend on phase
          phase = options[:phase]
          logger.debug "phase is #{phase}"

          # AMI id depends on phase
          if phase == 'gold_master'
            image_id = checkEnv('LEEROY_AWS_LINUX_AMI')
          elsif phase == 'application'
            image_id = state.imageid
          end

          instance_params.phase = phase

          raise "unable to determine image ID for phase '#{phase}'" if image_id.nil?

          instance_params.image_id = image_id

          # user_data file depends on phase
          user_data = File.join(checkEnv('LEEROY_USER_DATA_PREFIX'), phase)
          if File.readable?(user_data)
            instance_params.user_data = IO.readlines(user_data).join('')
          else
            raise "You must provide a readable user data script at #{user_data}."
          end

          logger.debug "instance_params: #{instance_params.inspect}"

          instance_params

        rescue StandardError => e
          raise e
        end
      end
    end
  end
end
