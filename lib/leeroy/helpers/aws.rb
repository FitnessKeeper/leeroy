require 'aws-sdk'
require 'base64'

require 'leeroy/helpers'
require 'leeroy/helpers/env'

require 'leeroy/types/instance'
require 'leeroy/types/mash'
require 'leeroy/types/semaphore'

module Leeroy
  module Helpers
    module AWS
      include Leeroy::Helpers

      attr :ec2, :s3

      def initialize(*args, &block)
        super(*args, &block)

        logger.debug "initializing AWS helpers"

        @ec2 = Aws::EC2::Client.new
        @s3 = Aws::S3::Client.new

        logger.debug "AWS helpers initialized"
      end

      # EC2

      def ec2Request(method, params = {}, ec2 = self.ec2, options = self.options, global_options = self.global_options)
        begin
          logger.debug "constructing EC2 request for '#{method}'"

          params_mash = Leeroy::Types::Mash.new(params)
          params = params_mash

          dry_run = global_options[:op] ? false : true

          params.dry_run = dry_run

          logger.debug "params: #{params.inspect}"

          ec2.send(method.to_sym, params)

        rescue StandardError => e
          raise e
        end
      end

      def getVpcId(vpcname, ec2 = self.ec2)
        begin
          logger.debug "getting VPC ID for '#{vpcname}'"

          resp = ec2Request(:describe_vpcs, {:filters => [{name: 'tag:Name', values: [vpcname]}]})
          vpcs = resp.vpcs
          logger.debug "vpcs: #{vpcs.inspect}"

          if vpcs.length < 1
            raise "No VPC found with the name '#{vpcname}'."
          elsif vpcs.length > 1
            raise "Multiple VPCs found with the name '#{vpcname}'."
          else
            vpcid = vpcs[0].vpc_id
          end

          logger.debug "vpcid: #{vpcid}"
          vpcid

        rescue Aws::EC2::Errors::DryRunOperation => e
          logger.info e.message
          "DRYRUN_DUMMY_VALUE: #{self.class.to_s}"

        rescue StandardError => e
          raise e
        end
      end

      def getSgId(sgname, vpcname, vpcid, ec2 = self.ec2)
        begin
          logger.debug "getting SG ID for '#{sgname}'"

          resp = ec2Request(:describe_security_groups, {:filters => [{name: 'vpc-id', values: [vpcid]}]})
          security_groups = resp.security_groups

          # now filter by sgname
          sgmatcher = %r{#{vpcname}-#{sgname}-.*}
          security_group = security_groups.select { |sg| sg.group_name =~ sgmatcher}
          logger.debug "security_group: #{security_group.inspect}"

          if security_group.length < 1
            raise "No SG found with the name '#{sgname}'."
          elsif security_group.length > 1
            raise "Multiple SGs found with the name '#{sgname}'."
          else
            sgid = security_group[0].group_id
          end

          logger.debug "sgid: #{sgid}"
          sgid

        rescue Aws::EC2::Errors::DryRunOperation => e
          logger.info e.message
          "DRYRUN_DUMMY_VALUE: #{self.class.to_s}"

        rescue StandardError => e
          raise e
        end
      end

      def getSubnetId(subnetname, vpcid, ec2 = self.ec2)
        begin
          logger.debug "getting Subnet ID for '#{subnetname}'"

          resp = ec2Request(:describe_subnets, {:filters => [{name: 'vpc-id', values: [vpcid]}, {name: 'tag:Name', values: [subnetname]}]})
          subnets = resp.subnets
          logger.debug "subnets: #{subnets.inspect}"

          if subnets.length < 1
            raise "No Subnet found with the name '#{subnetname}'."
          elsif subnets.length > 1
            raise "Multiple Subnets found with the name '#{subnetname}'."
          else
            subnetid = subnets[0].subnet_id
          end

          logger.debug "subnetid: #{subnetid}"
          subnetid

        rescue Aws::EC2::Errors::DryRunOperation => e
          logger.info e.message
          "DRYRUN_DUMMY_VALUE: #{self.class.to_s}"

        rescue StandardError => e
          raise e
        end
      end

      def createInstance(state = self.state, env = self.env, ec2 = self.ec2, options = self.options)
        begin
          logger.debug "creating an EC2 instance"

          # gather the necessary parameters
          instance_params = Hashie::Mash.new

          instance_params.security_group_ids = Array(state.sgid)
          instance_params.subnet_id = state.subnetid

          instance_params.key_name = checkEnv('LEEROY_BUILD_SSH_KEYPAIR')
          instance_params.instance_type = checkEnv('LEEROY_BUILD_INSTANCE_TYPE')

          instance_params.min_count = 1
          instance_params.max_count = 1

          instance_params.store(:iam_instance_profile, {:name =>  checkEnv('LEEROY_BUILD_PROFILE_NAME')})

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

          instance = Leeroy::Types::Instance.new(instance_params)

          binding.irb

          user_data = instance.user_data
          logger.debug "user_data: #{user_data.inspect}"
          # instance_id = instance.instantiate

          exit

          # resp = ec2Request(:run_instances, run_params)
          #
          # instanceid = resp.instances[0].instance_id
          #
          # logger.debug "instanceid: #{instanceid}"
          #
          # state.instanceid = instanceid
          #
          # instanceid

        rescue Aws::EC2::Errors::DryRunOperation => e
          logger.info e.message
          "DRYRUN_DUMMY_VALUE: #{self.class.to_s}"

        rescue StandardError => e
          raise e
        end
      end

      def destroyInstance(state = self.state, env = self.env, ec2 = self.ec2, options = self.options)
        begin
          # did we get instance ID(s)?
          instanceids = options.fetch(:instance, nil)
          if instanceids.nil?
            instanceids = Array(state.instanceid)
          end

          logger.debug "instanceids: #{instanceids}"

          run_params = Leeroy::Types::Mash.new
          run_params.instance_ids = instanceids

          resp = ec2Request(:terminate_instances, run_params)

          logger.debug "resp: #{resp.awesome_inspect}"

          resp.terminating_instances.collect { |i| i.instance_id }.sort

        rescue Aws::EC2::Errors::DryRunOperation => e
          logger.info e.message
          "DRYRUN_DUMMY_VALUE: #{self.class.to_s}"

        rescue StandardError => e
          raise e
        end
      end


      def createImage(state = self.state, env = self.env, ec2 = self.ec2, options = self.options)
        begin

        rescue Aws::EC2::Errors::DryRunOperation => e
          logger.info e.message
          "DRYRUN_DUMMY_VALUE: #{self.class.to_s}"

        rescue StandardError => e
          raise e
        end
      end

      def createTags(tags = {}, resourceids = [], state = self.state, env = self.env, ec2 = self.ec2, options = self.options)
        begin
          if resourceids.length == 0
            if state.instanceid?
              logger.debug "no resourceids provided for tagging, defaulting to instanceid #{state.instanceid} from state"
              resourceids.push(state.instanceid.to_s)
            end
          end

          run_params = Leeroy::Types::Mash.new

          logger.debug "resourceids: #{resourceids}"
          run_params.resources = resourceids

          tag_array = tags.collect {|key,value| {'key' => key, 'value' => value}}

          logger.debug "tags: #{tags}"
          logger.debug "tag_array: #{tag_array}"
          run_params.tags = tag_array

          resp = ec2Request(:create_tags, run_params)

          logger.debug "resp: #{resp.awesome_inspect}"

        rescue Aws::EC2::Errors::DryRunOperation => e
          logger.info e.message
          "DRYRUN_DUMMY_VALUE: #{self.class.to_s}"

        rescue StandardError => e
          raise e
        end
      end

      def filterImages(selector, collector = lambda { |x| x }, state = self.state, env = self.env, ec2 = self.ec2, options = self.options)
        begin
          run_params = Leeroy::Types::Mash.new

          run_params.owners = ['self']

          resp = ec2Request(:describe_images, run_params)

          # now filter based on callback
          resp.images.select {|x| selector.call(x)}.collect {|x| collector.call(x)}

        rescue Aws::EC2::Errors::DryRunOperation => e
          logger.info e.message
          "DRYRUN_DUMMY_VALUE: #{self.class.to_s}"

        rescue StandardError => e
          raise e
        end
      end

      def getGoldMasterInstanceName(env_name = 'LEEROY_GOLD_MASTER_NAME')
        checkEnv(env_name)
      end

      def getApplicationInstanceName(index, env_app = 'LEEROY_APP_NAME', env_name = 'LEEROY_BUILD_TARGET')
        name_prefix = [checkEnv(env_app), checkEnv(env_name), index].join('-')
        logger.debug "name_prefix: #{name_prefix}"

        if index.nil?
          # determine the index by looking at existing images
          selector = lambda {|image| image.name =~ /^#{name_prefix}/}
          # and extract the names
          collector = lambda {|image| image.name}

          image_names = filterImages(selector, collector)
          logger.debug image_names.awesome_inspect
        end

      end

      # S3

      def s3Request(method, params = {}, s3 = self.s3, options = self.options, global_options = self.global_options)
        begin
          logger.debug "constructing S3 request for '#{method}'"

          params_mash = Leeroy::Types::Mash.new(params)
          params = params_mash

          logger.debug "params: #{params.inspect}"

          s3.send(method.to_sym, params)

        rescue StandardError => e
          raise e
        end
      end

      def buildS3ObjectName(key, type, prefixes = Leeroy::Env::S3_PREFIXES)
        begin
          logger.debug "building S3 prefix (key: #{key}, type: #{type})"
          pfx = Leeroy::Types::Mash.new(prefixes)
          root = pfx.jenkins
          prefix = pfx.fetch(type,type)

          # FIXME i should do this with URI
          [root, prefix, key].join('/')

        rescue StandardError => e
          raise e
        end
      end

      def setSemaphore(object, payload = '', bucket = checkEnv('LEEROY_S3_BUCKET'))
        begin
          logger.debug "setting a semaphore"

          semaphore = Leeroy::Types::Semaphore.new(bucket: bucket, object: object, payload: payload)
          logger.debug "semaphore: #{semaphore}"

          # FIXME put the semaphore in S3

          semaphore

        rescue StandardError => e
          raise e
        end
      end

    end
  end
end
