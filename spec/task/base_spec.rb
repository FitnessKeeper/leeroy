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
end
