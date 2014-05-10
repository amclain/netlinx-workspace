require 'netlinx/compile/extension/apw'
require 'test/netlinx/compile/discoverable'

describe NetLinx::Compile::Extension::APW do
  
  subject { NetLinx::Compile::Extension::APW }
  
  let(:path) { 'test\unit\workspace\extension\apw' }
  
  
  it { should respond_to :get_handler }
  
  it "handles .apw NetLinx workspace files" do
    subject.get_handler.extensions.should include 'apw'
    subject.get_handler.handler_class.should be_a NetLinx::Workspace
  end
  
end