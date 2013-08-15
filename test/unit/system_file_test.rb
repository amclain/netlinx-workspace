require 'test_helper'
require 'netlinx/system_file'
require 'netlinx/test/compilable'

describe NetLinx::SystemFile do
  before do
    @system_file = @object = NetLinx::SystemFile.new
  end
  
  after do
    @system_file = @object = nil
  end 
  
  it "has a name" do
    name = 'test-module-compiled'
    @system_file.name = name
    @system_file.name.must_equal name
  end
  
  it "has a type" do
    type = 'TKO'
    @system_file.type = type
    @system_file.type.must_equal type
  end
  
  it "has a path" do
    path = 'module-compiled\test-module-compiled.tko'
    @system_file.path = path
    @system_file.path.must_equal path
  end
  
  it "has a description" do
    description = 'this is a test file'
    @system_file.description = description
    @system_file.description.must_equal description
  end
  
  it "prints its name for to_s" do
    name = 'system file name'
    @system_file.name = name
    @system_file.to_s.must_equal name
  end
  
  it "has a reference to its parent System object" do
    assert_respond_to @system_file, :system
  end
end