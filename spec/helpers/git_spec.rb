require 'spec_helper'
require 'leeroy'
require 'leeroy/helpers'
require 'leeroy/helpers/env'
require 'rugged'

describe "Test Leeroy::Helpers::Git" do
  before(:each) do
    @git = Leeroy::Task::StaticAssets.new(options: { :phase => 'gold_master' })
    @h = @git.getShortCommitHash(pwd='.')
  end
  it "Test getShortCommitHash method" do
    expect(@h.length).to be(7)
  end
end
