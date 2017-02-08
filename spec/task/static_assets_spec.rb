require 'spec_helper'
require 'leeroy'
require 'leeroy/task'
require 'leeroy/helpers/aws'
require 'leeroy/helpers/inventory'
require 'leeroy/task/static_assets'

describe "Test Leeroy::Task::StaticAssets New" do
  before(:each) do
    @sa = Leeroy::Task::StaticAssets.new
  end
  it "get instance of Leeroy::Task::StaticAssets" do
    expect(@sa).to be_instance_of(Leeroy::Task::StaticAssets)
  end
  # Test that perform validates packer template syntax

end
