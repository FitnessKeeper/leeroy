require 'leeroy'
require 'leeroy/task'
require 'leeroy/helpers/aws'

module Leeroy
  module Task
    trace_levels = [:debug]
    Yell.new :stderr, :name => 'Leeroy::Task::Instantiate', :trace => trace_levels

    class Instantiate < Leeroy::Task::Base
      include Leeroy::Helpers::AWS

      def perform(args = self.args, options = self.options, global_options = self.global_options)
        begin
          super(args, options, global_options)

          # resolve VPC ID
          vpcname = checkEnv('LEEROY_BUILD_VPC')
          vpcid = getVpcId(vpcname)
          self.state.vpcid = vpcid

          # resolve security group
          sgname = checkEnv('LEEROY_BUILD_SECURITY_GROUP')
          sgid = getSgId(sgname, vpcname, vpcid)
          self.state.sgid = sgid

          # resolve subnet
          subnetname = checkEnv('LEEROY_BUILD_SUBNET')
          subnetid = getSubnetId(subnetname, vpcid)
          self.state.subnetid = subnetid

          # create instance
          instanceid = createInstance
          self.state.instanceid = instanceid

          dump_state

          logger.debug "done performing for #{self.class}"

        rescue StandardError => e
          raise e
        end
      end

    end
  end
end
