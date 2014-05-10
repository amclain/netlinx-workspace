require 'netlinx/compile/extension/apw'
require 'test/netlinx/compile/discoverable'

describe NetLinx::Compile::Extension::APW do
  # TODO: Convert to shared examples.
  # include Test::NetLinx::Compile::Discoverable
  
  let(:path) { 'test\unit\workspace\extension\apw' }
  
  
  it "handles .apw NetLinx workspace files" do
    # TODO: shared examples
    pending
    
    subject.get_handler.extensions.should include 'apw'
    subject.get_handler.handler_class.should be_a NetLinx::Workspace
  end
  
end