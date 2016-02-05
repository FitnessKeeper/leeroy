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

    end
  end
end
