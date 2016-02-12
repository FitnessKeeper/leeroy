require 'leeroy'
require 'leeroy/task'
require 'leeroy/helpers/aws'

module Leeroy
  module Task
    class Instantiate < Leeroy::Task::Base
      include Leeroy::Helpers::AWS

      def perform(args = self.args, options = self.options, global_options = self.global_options)
        begin
          super(args, options, global_options)

          phase = options[:phase]

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

          # tag instance
          if phase == 'gold_master'
            instance_name = getGoldMasterInstanceName
          elsif phase == 'application'
            instance_name = getApplicationInstanceName
          else
            raise "unable to determine instance name for phase '#{phase}'"
          end
          createTags({'Name' => instance_name})

          # write semaphore
          # FIXME read the payload from file reference in env var
          payload = 'DUMMY_PAYLOAD'
          s3_object = buildS3ObjectName(instance_name, 'semaphores')
          semaphore = setSemaphore(s3_object, payload)
          self.state.semaphore = semaphore

          dump_state

          logger.debug "done performing for #{self.class}"

        rescue StandardError => e
          raise e
        end
      end

    end
  end
end
