require 'test_helper'
require 'netlinx/compile/extension/apw'
require 'test/netlinx/compile/discoverable'

describe NetLinx::Compile::Extension::APW do
  include Test::NetLinx::Compile::Discoverable
  
  before do
    @path = 'test\unit\workspace\extension\apw'
    @apw  = @object = NetLinx::Compile::Extension::APW
  end
  
  after do
    @apw = @object = nil
  end
  
  it "handles .apw NetLinx workspace files" do
    @apw.get_handler.extensions.include?('apw').must_equal true
    @apw.get_handler.handler_class.must_equal NetLinx::Workspace
  end
end