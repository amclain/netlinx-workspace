require 'netlinx/workspace/system_file'
require 'test/netlinx/compilable'

describe NetLinx::SystemFile do
  
  subject {
    NetLinx::SystemFile.new \
      system: system,
      name: name,
      type: type,
      path: path,
      description: description
  }
  
  let(:type) { :tko }
  let(:name) { 'tp_1' }
  let(:path) { 'touch-panel/tp_1.TP4' }
  let(:description) { 'this is a test file' }
  let(:system) { double() }
  
  its(:name) { should eq name }
  its(:type) { should eq type }
  its(:path) { should eq path }
  its(:description) { should eq description }
  its(:system) { should eq system }
  its(:to_s) { should eq name }
  
  shared_context "device map" do
    let(:dps_1) { '10001:1:0' }
    let(:dps_2) { '10002:1:0' }
    
    before {
      subject << dps_1
      subject << dps_2
    }
  end
  
  describe "device map" do
    include_context "device map"
    
    its(:devices) { should be_an Array }
    
    it "includes DPS 1 and 2" do
      subject.devices.should include dps_1
      subject.devices.should include dps_2
    end
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
      
      element.elements['DeviceMap'].should eq nil
    end
    
    describe "with device map" do
      include_context "device map"
      
      specify do
        element.elements['DeviceMap'].attributes['DevAddr'].should eq "Custom [#{dps_1}]"
        element.elements['DeviceMap'].elements['DevName'].first.should eq "Custom [#{dps_1}]"
      end
    end
  end
  
end