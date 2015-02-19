require 'netlinx/workspace'
require 'netlinx/compiler'
require 'test/netlinx/compile/invokable'

describe NetLinx::Workspace do
  
  subject {
    NetLinx::Workspace.new \
      name: name,
      description: description
  }
  
  let(:name) { 'Test Workspace' }
  let(:description) { 'Test Description' }
  
  let(:workspace_path) { 'spec/workspace/import-test' }
  
  it { should respond_to :compile }
  
  its(:name) { should eq name }
  its(:description) { should eq description }
  
  it "contains projects" do
    subject.projects.should eq []
  end
  
  it "prints its name for to_s" do
    subject.to_s.should eq name
  end
  
  it "can add a project with <<" do
    project = NetLinx::Project.new
    subject << project
    subject.projects.first.should eq project
    project.workspace.should eq subject
  end
  
  it "exposes a directory path that the workspace resides in" do
    subject = NetLinx::Workspace.new \
      file: File.expand_path('import-test.apw', workspace_path)
      
    subject.path.should eq File.dirname(File.expand_path('import-test.apw', workspace_path))
  end
  
  it "exposes the path to the .apw workspace file" do
    subject = NetLinx::Workspace.new \
      file: File.expand_path('import-test.apw', workspace_path)
      
    subject.file.should eq File.expand_path('import-test.apw', workspace_path)
  end
  
  it "can be initialized from a .axw file" do
    # Import the test project.
    subject = NetLinx::Workspace.new \
      file: File.expand_path('import-test.apw', workspace_path)
      
    subject.name.should eq 'import-test'
    subject.description.should eq 'For testing Ruby import.'
    
    # Check project data.
    subject.projects.count.should eq 1
    project = subject.projects.first
    
    project.name.should eq           'import-test-project'
    project.dealer.should eq         'Test Dealer'
    project.designer.should eq       'Test Designer'
    project.sales_order.should eq    'Test Sales Order'
    project.purchase_order.should eq 'Test PO'
    project.description.should eq    'Test project description.'
    
    # Check system data.
    project.systems.count.should eq 1
    system = project.systems.first
    
    system.name.should eq        'import-test-system'
    system.id.should eq          0
    system.description.should eq 'Test system description.'
    
    # Contains the MasterSrc file to be compiled.
    system.compiler_target_files.should include \
      File.expand_path('import-test.axs', workspace_path)
    
    # Contains include paths.
    system.compiler_include_paths.should include \
      File.expand_path('include', workspace_path)
    
    # Contains module paths.
    system.compiler_module_paths.should include \
      File.expand_path('duet-module', workspace_path)
    
    # Contains compiled module path.
    system.compiler_module_paths.should include \
      File.expand_path('module-compiled', workspace_path)
    
    # Contains compiled module path.
    system.compiler_module_paths.should include \
      File.expand_path('module-source', workspace_path)
  end
  
  describe "can invoke the compiler on itself" do
    let(:project) { NetLinx::Project.new name: 'Test Project' }
    
    let(:system_1) { NetLinx::System.new name: 'Test System 1' }
    let(:system_2) { NetLinx::System.new name: 'Test System 2' }
    
    before {
      subject << project
      project << system_1
      project << system_2
    }
    
    it { should respond_to :compile }
    
    specify do
      mock_compiler = double()
      NetLinx::Compiler.should_receive(:new).twice { mock_compiler }
      mock_compiler.should_receive(:compile).twice { [] }
      
      subject.compile
    end
  end
  
  it "can check if a file is included in the workspace" do
    subject = NetLinx::Workspace.new \
      file: File.expand_path('import-test.apw', workspace_path)
    
    subject.should respond_to :include?
    
    # Can find file by relative path.
    subject.should include 'import-test.axs'
    
    # Can find file by absolute path.  
    subject.should include File.expand_path('include/import-include.axi', workspace_path)
    
    # Can find file by element name.
    subject.should include 'import-test'
    
    # Returns false for an element name that doesn't exist.  
    subject.should_not include 'does-not-exist'
    
    # Returns false for a relative path that doesn't exist.
    subject.should_not include 'does-not-exist.axs'
    
    # Returns false for an absolute path that doesn't exist.
    subject.should_not include File.expand_path('does-not-exist.axi', workspace_path)
  end
  
  describe "workspace search" do
    subject { NetLinx::Workspace }
    
    let(:subpath) { "#{workspace_path}/include" }
    
    it "can find workspace" do
      workspace = subject.search dir: subpath
      
      workspace.should be_a NetLinx::Workspace
      workspace.path.should eq File.expand_path(workspace_path)
    end
    
    it "returns nil if no workspace found" do
      subject.search(dir: '/').should be nil
    end
  end
  
  describe "xml output" do
    let(:project) { NetLinx::Project.new name: project_name }
    let(:project_name) { 'Test Project' }
    
    let(:element) { subject.to_xml_element }
    let(:xml_string) { subject.to_xml }
    
    before { subject << project }
    
    describe "element" do
      it { should respond_to :to_xml_element }
      
      specify do
        element.should be_a REXML::Element
        
        element.name.should eq 'Workspace'
        
        element.attributes['CurrentVersion'].should eq '4.0'
        
        element.elements['Identifier'].first.should eq name
        element.elements['CreateVersion'].first.should eq '4.0'
        element.elements['Comments'].first.should eq description
        
        element.elements['Project/Identifier'].first.should eq project_name
      end
    end
    
    describe "string" do
      it { should respond_to :to_xml }
      
      specify do
        xml_string.should be_a String
        
        xml_string.should include name
        xml_string.should include description
        xml_string.should include project_name
      end
    end
    
    describe "retains resolution when converted through xml" do
      let(:system) {
        NetLinx::System.new \
          name: 'Test System',
          id: 3,
          description: 'Test System',
          ip_address: '192.168.253.2',
          ip_port: 5001,
          com_port: :com2,
          baud_rate: 115200
      }
      
      let(:file) {
        NetLinx::SystemFile.new(
          type: :include,
          name: 'test-file',
          path: 'include/test-file.axi',
          description: 'Test file description.'
        ).tap do |file|
          file << dps_1
          file << dps_2
        end
      }
      
      let(:dps_1) { '10001:1:0' }
      let(:dps_2) { '10002:1:0' }
      
      before { project << system; system << file }
      
      specify do
        new_workspace = NetLinx::Workspace.new.parse_xml xml_string
        
        new_workspace.name.should        eq subject.name
        new_workspace.description.should eq subject.description
        
        new_project = new_workspace.projects.first
        
        new_project.name.should           eq project.name
        new_project.description.should    eq project.description
        new_project.dealer.should         eq project.dealer
        new_project.designer.should       eq project.designer
        new_project.sales_order.should    eq project.sales_order
        new_project.purchase_order.should eq project.purchase_order
        
        new_system = new_project.systems.first
        
        new_system.name.should                eq system.name
        new_system.id.should                  eq system.id
        new_system.description.should         eq system.description
        new_system.ip_address.should          eq system.ip_address
        new_system.ip_port.should             eq system.ip_port
        new_system.ensure_availability.should eq system.ensure_availability
        new_system.com_port.should            eq system.com_port
        new_system.baud_rate.should           eq system.baud_rate
        new_system.data_bits.should           eq system.data_bits
        new_system.parity.should              eq system.parity
        new_system.stop_bits.should           eq system.stop_bits
        new_system.flow_control.should        eq system.flow_control
        
        new_file = new_system.files.first
        
        new_file.name.should        eq file.name
        new_file.path.should        eq file.path
        new_file.description.should eq file.description
        new_file.type.should        eq file.type
        
        new_file.devices.should eq [dps_1, dps_2]
      end
    end
    
  end
  
end
