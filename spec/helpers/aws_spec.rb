require 'spec_helper'
require 'leeroy'
require 'leeroy/helpers'
require 'leeroy/helpers/aws'
require 'leeroy/helpers/env'

#ENV['AWS_ACCESS_KEY_ID'] = 'AAAAAAAAAAAAAAAAAAAA'
#ENV['AWS_SECRET_ACCESS_KEY'] = 'DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD'
=begin
describe "Test Leeroy::Helpers::Aws" do
  before(:each) do
    @sa = Leeroy::Task::StaticAssets.new(options: { :phase => 'gold_master' })
    @creds = @sa.getCredentials
  end
  it "Test getCredentials method" do
    expect(@creds).to include(:access_key_id, :secret_access_key)
  end
end
=end 
