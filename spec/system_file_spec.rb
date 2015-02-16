require 'netlinx/system_file'
require 'test/netlinx/compilable'

describe NetLinx::SystemFile do
  
  it "has a name" do
    name = 'test-module-compiled'
    subject.name = name
    subject.name.should eq name
  end
  
  it "has a type" do
    type = 'TKO'
    subject.type = type
    subject.type.should eq type
  end
  
  it "has a path" do
    path = 'module-compiled\test-module-compiled.tko'
    subject.path = path
    subject.path.should eq path
  end
  
  it "has a description" do
    description = 'this is a test file'
    subject.description = description
    subject.description.should eq description
  end
  
  it "prints its name for to_s" do
    name = 'system file name'
    subject.name = name
    subject.to_s.should eq name
  end
  
  it "has a reference to its parent System object" do
    subject.should respond_to :system
  end
  
  describe "xml output" do
    subject {
      NetLinx::SystemFile.new \
        type: type,
        name: name,
        path: path,
        description: description
    }
    
    let(:element) { subject.to_xml_element }
    
    let(:type) { :include }
    let(:name) { 'Test File' }
    let(:path) { 'test_file.axi' }
    let(:description) { 'File description.' }
    
    it { should respond_to :to_xml_element }
    
    specify do
      element.should be_a REXML::Element
      
      element.name.should eq 'File'
      
      element.attributes['CompileType'].should eq 'Netlinx'
      element.attributes['Type'].should eq 'Include'
      
      element.elements['Identifier'].first.should eq name
      element.elements['FilePathName'].first.should eq path
      element.elements['Comments'].first.should eq description
      
    end
  end
  
end