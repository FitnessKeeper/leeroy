require 'aws-sdk'
require 'base64'

require 'leeroy/helpers'
require 'leeroy/helpers/env'

require 'leeroy/types/mash'

module Leeroy
  module Helpers
    module AWS
      include Leeroy::Helpers

      attr :ec2, :s3

      def initialize(params = {})
        super(params)

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

        rescue StandardError => e
          raise e
        end
      end

      def createInstance(state = self.state, env = self.env, ec2 = self.ec2, options = self.options)
        begin
          logger.debug "creating an EC2 instance"

          # gather the necessary parameters
          run_params = Hashie::Mash.new

          # run_params.store(:security_group_ids, Array(state.sgid))
          run_params.security_group_ids = Array(state.sgid)
          run_params.subnet_id = state.subnetid

          run_params.image_id = checkEnv('LEEROY_AWS_LINUX_AMI')
          run_params.key_name = checkEnv('LEEROY_BUILD_SSH_KEYPAIR')
          run_params.instance_type = checkEnv('LEEROY_BUILD_INSTANCE_TYPE')

          run_params.min_count = 1
          run_params.max_count = 1

          run_params.store(:iam_instance_profile, {:name =>  checkEnv('LEEROY_BUILD_PROFILE_NAME')})

          # user_data file depends on options
          phase = options[:phase]
          user_data = File.join(checkEnv('LEEROY_USER_DATA_PREFIX'), phase)
          if File.readable?(user_data)
            run_params.user_data = Base64.urlsafe_encode64(IO.readlines(user_data).join(''))
          else
            raise "You must provide a readable user data script at #{user_data}."
          end

          logger.debug "run_params: #{run_params.inspect}"

          resp = ec2Request(:run_instances, run_params)

          instanceid = resp.instances[0].instance_id

          logger.debug "instanceid: #{instanceid}"

          state.instanceid = instanceid

          instanceid

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

        rescue StandardError => e
          raise e
        end
      end

      # S3

      def setSemaphore(key, payload = '', path = '')
        begin

        rescue StandardError => e
          raise e
        end
      end

    end
  end
end
