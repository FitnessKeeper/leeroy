require 'spec_helper'
require 'leeroy'
require 'leeroy/task'
require 'leeroy/task/packer'
require 'leeroy/helpers/aws'
require 'leeroy/helpers/inventory'

describe "Test Leeroy::Types::Packer New" do
  before(:each) do
    @packer = Leeroy::Types::Packer.new
  end
  it "get instance of Leeroy::Types::Packer" do
    expect(@packer).to be_instance_of(Leeroy::Types::Packer)
  end
  # Test that perform validates packer template syntax

  it "Check that ::Types::Packer initialized correctly" do
    expect(@packer.packer_vars).to include(:aws_linux_ami, :app_name, :aws_region, :packer_template_prefix)
  end
  #{"packer_vars"=>[:aws_linux_ami, :app_name, :aws_region]}
end
