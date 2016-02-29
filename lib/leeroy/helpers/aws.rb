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
          logger.debug "params: #{params.inspect}"

          params_mash = Leeroy::Types::Mash.new(params)
          params = params_mash

          dry_run = global_options[:op] ? false : true

          params.dry_run = dry_run

          logger.debug "params: #{params.inspect}"

          resp = ec2.send(method.to_sym, params)

          logger.debug "resp: #{resp.inspect}"

          resp

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

          resp.terminating_instances.collect { |i| i.instance_id }.sort

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

      def getGoldMasterImageIndex(env_prefix = 'LEEROY_GOLD_MASTER_IMAGE_PREFIX')
        name_prefix = checkEnv(env_prefix)
        logger.debug "name_prefix: #{name_prefix}"

        # determine the index by looking at existing images
        selector = lambda {|image| image.name =~ /^#{name_prefix}/}
        # and extract the names
        collector = lambda {|image| image.name}

        image_names = filterImages(selector, collector)
        image_numbers = image_names.collect do |name|
          if name =~ /(\d+)$/
            image_number = $1.to_i
          end
        end

        latest_image = image_numbers.sort.compact.uniq.pop
        logger.debug "latest_image: #{latest_image}"

        latest_image

      end

      # S3

      def s3Request(method, params = {}, s3 = self.s3, options = self.options, global_options = self.global_options)
        begin
          logger.debug "constructing S3 request for '#{method}'"

          params_mash = Leeroy::Types::Mash.new(params)
          params = params_mash

          logger.debug "params: #{params.inspect}"

          resp = s3.send(method.to_sym, params)

          logger.debug "resp: #{resp.inspect}"

          resp

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

      def genSemaphore(object, payload = '', bucket = checkEnv('LEEROY_S3_BUCKET'))
        begin
          logger.debug "creating a semaphore"

          semaphore = Leeroy::Types::Semaphore.new(bucket: bucket, object: object, payload: payload)
          logger.debug "semaphore: #{semaphore}"

          semaphore

        rescue StandardError => e
          raise e
        end
      end

      def setSemaphore(semaphore)
        begin
          unless semaphore.kind_of?(Leeroy::Types::Semaphore)
            semaphore = Leeroy::Types::Semaphore.new(semaphore)
          end

          logger.debug "setting a semaphore"

          run_params = Leeroy::Types::Mash.new

          run_params.body = semaphore.payload
          run_params.bucket = semaphore.bucket
          run_params.key = semaphore.object

          resp = s3Request(:put_object, run_params)

          semaphore

        rescue StandardError => e
          raise e
        end
      end

      def clearSemaphore(semaphore)
        begin
          logger.debug "semaphore.class: #{semaphore.class}"

          if semaphore.kind_of?(Leeroy::Types::Semaphore)
            logger.debug "received a semaphore, continuing"
          else
            logger.debug "did not receive a semaphore, initializing"
            semaphore = Leeroy::Types::Semaphore.new(semaphore)
          end

          run_params = Leeroy::Types::Mash.new
          run_params.bucket = semaphore.bucket
          run_params.key = semaphore.object

          # is the object present in S3?
          resp = checkSemaphore(semaphore)

          if checkSemaphore(semaphore)
            logger.debug "#{semaphore} present, deleting"
            resp = s3Request(:delete_object, run_params)
          else
            logger.debug "#{semaphore} not present, continuing"
          end

          semaphore

        rescue StandardError => e
          raise e
        end
      end

      def checkSemaphore(semaphore)
        begin
          unless semaphore.kind_of?(Leeroy::Types::Semaphore)
            semaphore = Leeroy::Types::Semaphore.new(semaphore)
          end

          run_params = Leeroy::Types::Mash.new
          run_params.bucket = semaphore.bucket
          run_params.key = semaphore.object

          # is the object present in S3?
          logger.debug "checking for presence of #{semaphore}"
          resp = s3Request(:head_object, run_params)

          if resp.delete_marker.nil?
            resp
          else
            logger.debug "#{semaphore} already deleted"
            nil
          end

        rescue Aws::S3::Errors::NotFound => e
          logger.debug "#{semaphore} not found"
          nil

        rescue StandardError => e
          raise e
        end
      end

    end
  end
end
