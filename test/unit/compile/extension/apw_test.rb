require 'test_helper'
require 'netlinx/compile/extension/apw'
require 'test/netlinx/compile/invokable'

describe NetLinx::Compile::Extension::APW do
  include Test::NetLinx::Compile::Invokable
  
  before do
    @path = 'test\unit\workspace\extension\apw'
    @apw = @object = NetLinx::Compile::Extension::APW.new
  end
  
  after do
    @apw = @object = nil
  end
  
  it "invokes the compiler for a file with the .apw extension" do
    source = File.expand_path 'apw-test.apw', @path
    destination = File.expand_path 'apw-test.tkn', @path
    File.delete destination if File.exists? destination
    
    @apw.invoke_compile target: source
    
    File.exists?(destination).must_equal true
  end
  
  it "raises ArgumentError if the target is not specified" do
    Proc.new {
      @apw.invoke_compile
    }.must_raise ArgumentError
  end
  
  it "returns a compiler result" do
    source = File.expand_path 'apw-test.apw', @path
    
    @apw.invoke_compile(target: source).first
      .is_a?(NetLinx::CompilerResult).must_equal true
  end
end