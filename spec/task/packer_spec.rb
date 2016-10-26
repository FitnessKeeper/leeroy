require 'spec_helper'
require 'leeroy'
require 'leeroy/task'
require 'leeroy/task/packer'
require 'leeroy/helpers/aws'
require 'leeroy/helpers/inventory'

describe "Test Leeroy::Task::Packer New" do
  before(:each) do
    @packer = Leeroy::Task::Packer.new
  end
  it "get instance of Leeroy::Task::Packer" do
    expect(@packer).to be_instance_of(Leeroy::Task::Packer)
  end
end
