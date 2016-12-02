require 'spec_helper'
require 'leeroy'
require 'leeroy/env'
require 'leeroy/helpers'
require 'leeroy/helpers/env'
require 'leeroy/helpers/logging'
require 'leeroy/helpers/state'
require 'leeroy/state'
require 'leeroy/task'
require 'leeroy/types/mash'

describe "Test Leeroy::Task::Base New" do
  before(:each) do
    @base = Leeroy::Task::Base.new
  end
  it "get instance of Leeroy::Task::Base" do
    expect(@base).to be_instance_of(Leeroy::Task::Base)
  end
  it "Check .global_options is an empty hash" do
    expect(@base.global_options).to eq({})
  end
  it "Check .args is an empty hash" do
    expect(@base.args).to eq({})
  end
  it "Check .state is initialized" do
    expect(@base.state).to include(:data, :metadata )
    expect(@base.state.metadata).to include(:task, :previous, :started )
    expect(@base.state.metadata.task).to eq("Leeroy::Task::Base")
  end
  it "responds to .global_options" do
    expect(@base).to respond_to(:global_options)
  end
  it "responds to .args" do
    expect(@base).to respond_to(:args)
  end
  it "responds to .state" do
    expect(@base).to respond_to(:state)
  end
end

describe "Test Leeroy::Task::Base New with global_options" do
  before(:each) do
    @base = Leeroy::Task::Base.new(:global_options => {:foo => "bar"})
  end
  it "get instance of Leeroy::Task::Base" do
    expect(@base).to be_instance_of(Leeroy::Task::Base)
  end
  it "Check .global_options has the content we want" do
    expect(@base.global_options).to eq({:foo => "bar"})
    expect(@base.global_options.fetch(:foo)).to eq("bar")
  end
end
