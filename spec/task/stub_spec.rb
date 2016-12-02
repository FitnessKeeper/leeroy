require 'leeroy/task'


describe "Test Leeroy::Task::Stub New" do
  before(:each) do
    @stub = Leeroy::Task::Stub.new
  end
  it "get instance of Leeroy::Task::Stub" do
    expect(@stub).to be_instance_of(Leeroy::Task::Stub)
  end

  #stub.state.data
  it "responds to .perform" do
    expect(@stub).to respond_to(:perform)
  end

  it "Check that perform added a message to the .state.data hash" do
    @stub.perform
    expect(@stub.state.data).to include(:message)
    expect(@stub.state.data.message).to eq('0')
    @stub.perform
    expect(@stub.state.data.message).should_not eq('1')
  end
end


describe 'Test Leeroy::Task::Stub New { :increment => "1"}' do
  before(:each) do
    @stub = Leeroy::Task::Stub.new(:options => { :increment => "1"})
  end
  it "Check :message can be incremented by 1" do
    @stub.perform
    expect(@stub.state.data).to include(:message)
    expect(@stub.state.data.message).to eq('1')
    @stub.perform
    expect(@stub.state.data.message).to eq('2')
  end
end
