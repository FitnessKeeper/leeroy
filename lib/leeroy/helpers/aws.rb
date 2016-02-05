require 'aws-sdk'

require 'leeroy/helpers'
require 'leeroy/helpers/env'

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

      def ec2Request(method, params = {}, ec2 = self.ec2, options = self.options, global_options = self.global_options)
        begin
          logger.debug "constructing EC2 request for '#{method}'"

          dry_run = global_options[:op] ? false : true

          params[:dry_run] = dry_run

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

    end
  end
end
