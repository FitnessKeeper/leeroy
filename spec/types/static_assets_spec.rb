require 'spec_helper'
require 'leeroy'
require 'leeroy/task'
require 'leeroy/helpers/aws'
require 'leeroy/types/static_assets'

describe "Test Leeroy::Types::StaticAssets New" do
  before(:each) do
    @sa = Leeroy::Types::StaticAssets.new
  end
  it "get instance of Leeroy::Types::StaticAssets" do
    expect(@sa).to be_instance_of(Leeroy::Types::StaticAssets)
  end

  it "Check that ::Types::StaticAssets initialized correctly" do
    expect(@sa.static_assets_vars).to include(:aws_region, :static_asssets_path, :static_asssets_s3_prefix, :static_asssets_s3_bucket )
  end
end
