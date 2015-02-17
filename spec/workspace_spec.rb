require 'netlinx/workspace'
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
      
    subject.name.should eq    'import-test'
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
  
  it "can invoke the compiler on itself" do
    subject.should respond_to :compile
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
    
    before { subject << project }
    
    describe "element" do
      let(:element) { subject.to_xml_element }
      
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
      let(:xml_string) { subject.to_xml }
      
      it { should respond_to :to_xml }
      
      specify do
        xml_string.should be_a String
        
        xml_string.should include name
        xml_string.should include description
        xml_string.should include project_name
      end
    end
  end
  
end
