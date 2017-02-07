require 'spec_helper'
require 'leeroy'
require 'leeroy/task'
require 'leeroy/helpers/aws'
require 'leeroy/helpers/inventory'

describe "Test Leeroy::Task::Static_assets New" do
  before(:each) do
    @sa = Leeroy::Task::Static_assets.new
  end
  it "get instance of Leeroy::Task::Static_assets" do
    expect(@sa).to be_instance_of(Leeroy::Task::Static_assets)
  end
  # Test that perform validates packer template syntax

end
