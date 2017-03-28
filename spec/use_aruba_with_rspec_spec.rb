require 'spec_helper'

RSpec.describe 'version', :type => :aruba do
  skip "is boilerplate" do
    @announce
    let(:file) { 'file.txt' }
    let(:content) { 'Hello World' }

    before(:each) { write_file file, content }

    it { expect(read(file)).to eq [content] }
  end
end
