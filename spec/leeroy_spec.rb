require 'spec_helper'
require 'leeroy'
require 'leeroy/task/fixture'
require 'leeroy/task/image'
require 'leeroy/task/instantiate'
require 'leeroy/task/terminate'
require 'leeroy/task/sleep'
require 'leeroy/task/stub'
require 'leeroy/types/fixture'
require 'leeroy/types/phase'

ENV["AWS_REGION"] = "us-east-1"
describe "Test Leeroy::Env New" do
  before(:each) do
    @env = Leeroy::Env.new
  end
  it "get instance of Leeroy::Env" do
    expect(@env).to be_instance_of(Leeroy::Env)
  end
end

describe "Test Leeroy::Task::Fixture New" do
  before(:each) do
    @fixture = Leeroy::Task::Fixture.new
  end
  it "get instance of Leeroy::Task::Fixture" do
    expect(@fixture).to be_instance_of(Leeroy::Task::Fixture)
  end
end


#image
#instantiate
#sleep
#stub
#terminate
#version
