require 'netlinx/workspace/system'
require 'test/netlinx/compilable'
require 'ostruct'
require 'rexml/document'

describe NetLinx::System do
  
  subject {
    NetLinx::System.new \
      project: project,
      id: id,
      name: name,
      active: active,
      description: description,
      ip_address: ip_address,
      com_port: com_port,
      baud_rate: baud_rate
  }
  
  let(:name)        { 'Test System' }
  let(:id)          { 2 }
  let(:active)      { false }
  let(:description) { 'Test description.' }
  let(:ip_address)  { '192.168.1.2' }
  let(:com_port)    { :com2 }
  let(:baud_rate)   { 57600 }
  
  let(:workspace) { OpenStruct.new path: File.expand_path('spec/workspace/import-test') }
  let(:project)   { OpenStruct.new workspace: workspace }
  
  let(:master_src_file) {
    OpenStruct.new \
      type: :master,
      name: 'import-test',
      path: 'import-test.axs',
      system: subject
  }
  
  let(:include_file) {
    OpenStruct.new \
      type: :include,
      name: 'import-include',
      path: 'include/import-include.axi',
      system: subject
  }
  
  let(:source_module) {
    OpenStruct.new \
      type: :module,
      name: 'test-module-source',
      path: 'module-source/test-module-source.axs',
      system: subject
  }
  
  let(:compiled_module) {
    OpenStruct.new \
      type: :tko,
      name: 'test-module-compiled',
      path: 'module-compiled/test-module-compiled.tko',
      system: subject
  }
  
  let(:duet_module) {
    OpenStruct.new \
      type: :duet,
      name: 'duet-lib-pjlink_dr0_1_1',
      path: 'duet-module/duet-lib-pjlink_dr0_1_1.jar',
      system: subject
  }
  
  describe "stores project data" do
    its(:name) { should eq name }
    its(:id) { should eq id }
    its(:active) { should eq active }
    its(:description) { should eq description }
    its(:files) { should eq [] }
  end
  
  describe "is compilable" do
    describe "interface" do
      # Converted from Test::NetLinx::Compilable
      # https://github.com/amclain/netlinx-compile/blob/master/lib/test/netlinx/compilable.rb
      specify "compilable" do
        [
          :compiler_target_files,
          :compiler_include_paths,
          :compiler_library_paths,
          :compiler_module_paths,
        ].each { |method|
          subject.should respond_to method
          subject.send(method).should be_a Array 
        }
      end
    end
    
    it "can invoke the compiler on itself" do
      subject.should respond_to :compile
    end
    
    it "exposes one master source file as the target file to compile" do
      subject << master_src_file
      subject.compiler_target_files.count.should eq 1
      subject.compiler_target_files.should include \
        File.expand_path('import-test.axs', workspace.path)
    end
    
    it "lists .axi file paths under include paths" do
      subject << include_file
      subject.compiler_include_paths.should include \
        File.expand_path('include', workspace.path)
    end
    
    it "lists source, compiled, and duet modules under module paths" do
      subject.compiler_module_paths.count.should eq 0
      
      subject << source_module
      subject.compiler_module_paths.count.should eq 1
      subject.compiler_module_paths.should include \
        File.expand_path('module-source', workspace.path)
      
      subject << compiled_module
      subject.compiler_module_paths.count.should eq 2
      subject.compiler_module_paths.should include \
        File.expand_path('module-compiled', workspace.path)
      
      subject << duet_module
      subject.compiler_module_paths.count.should eq 3
      subject.compiler_module_paths.should include \
        File.expand_path('duet-module', workspace.path)
    end
    
    it "returns an empty library path" do
      subject.compiler_library_paths.count.should eq 0
    end
  end
  
  it "outputs its name for to_s" do
    subject.to_s.should eq name
  end
  
  it "can add a file with <<" do
    f = OpenStruct.new
    subject << f
    subject.files.first.should eq f
    f.system.should eq subject
  end
  
  it "stores a reference to its parent project" do
    subject.should respond_to :project
  end
  
  it "can check if a file is included in the system" do
    subject.should respond_to :include?
    
    subject << include_file
    
    subject.should include 'import-include'
    subject.should include 'include/import-include.axi'
    subject.should_not include 'does-not-exist'
    subject.should_not include 'include/does-not-exist.axi'
  end
  
  describe "compilable path methods" do
    specify "don't contain duplicates" do
      subject << include_file
      subject << include_file
      
      subject.compiler_include_paths.count.should eq 1
    end
    
    describe "return native Ruby (Unix-style) paths" do
      # Adds compatibility for CI tools.
      specify do
        file = OpenStruct.new \
          type: :include,
          name: 'import-include',
          path: 'include\import-include.axi', # Dos-style backslash
          system: subject
        
        subject << file
        
        subject.compiler_include_paths.first.end_with?('/include').should eq true
      end
    end
  end
  
  describe "communication settings" do
    describe "network" do
      describe "interface" do
        it { should respond_to :ip_address }
        it { should respond_to :ip_address= }
        it { should respond_to :ip_port }
        it { should respond_to :ip_port= }
        it { should respond_to :ensure_availability }
        it { should respond_to :ensure_availability= }
      end
    end
    
    describe "serial" do
      describe "interface" do
        it { should respond_to :com_port }
        it { should respond_to :com_port= }
        it { should respond_to :baud_rate }
        it { should respond_to :baud_rate= }
        it { should respond_to :data_bits }
        it { should respond_to :data_bits= }
        it { should respond_to :parity }
        it { should respond_to :parity= }
        it { should respond_to :stop_bits }
        it { should respond_to :stop_bits= }
        it { should respond_to :flow_control }
        it { should respond_to :flow_control= }
      end
    end
  end
  
  describe "xml output" do
    let(:file) { NetLinx::SystemFile.new name: file_name }
    let(:file_name) { 'Test File' }
    
    let(:element) { subject.to_xml_element }
    
    before { subject << file }
    
    it { should respond_to :to_xml_element }
    
    specify do
      element.should be_a REXML::Element
      
      element.name.should eq 'System'
      
      element.attributes['IsActive'].should eq 'false'
      element.attributes['Platform'].should eq 'Netlinx'
      
      element.elements['Identifier'].first.should eq name
      element.elements['SysID'].first.should eq id
      element.elements['Comments'].first.should eq description
      
      # These communication settings are important for FileTransfer 2 and
      # NetLinx Studio <= 3
      element.elements['TransTCPIP'].first.should eq "#{ip_address},1319,1,,,"
      element.elements['TransSerial'].first.should eq "COM2,57600,8,None,1,,,"
      
      # These communication settings are important for NetLinx Studio 4.
      element.elements['TransTCPIPEx'].first.should eq "#{ip_address}|1319|1|||"
      element.elements['TransSerialEx'].first.should eq "COM2|57600|8|None|1|||"
      
      element.elements['File/Identifier'].first.should eq file_name
    end
    
    describe "Transport" do
      it "is TCPIP if IP address is specified" do
        element.attributes['Transport'].should eq 'TCPIP'
        element.attributes['TransportEx'].should eq 'TCPIP'
      end
      
      it "is Serial if IP address is 0.0.0.0" do
        subject.ip_address = '0.0.0.0'
        element.attributes['Transport'].should eq 'Serial'
        element.attributes['TransportEx'].should eq 'Serial'
      end
    end
    
    describe "IsActive" do
      describe "is false" do
        let(:active) { false }
        specify { element.attributes['IsActive'].should eq active.to_s }
      end
      
      describe "is true" do
        let(:active) { true }
        specify { element.attributes['IsActive'].should eq active.to_s }
      end
    end
  end
  
end
