require 'netlinx/workspace'
require 'test/netlinx/compile/invokable'

describe NetLinx::Workspace do
  
  let(:workspace_path) { 'spec/workspace/import-test' }
  
  
  it { should respond_to :compile }
  
  it "has a name" do
    name = 'my workspace'
    subject.name = name
    subject.name.should eq name
  end
  
  it "has a description" do
    description = 'test description'
    subject.description = description
    subject.description.should eq description
  end
  
  it "contains projects" do
    subject.projects.should eq []
  end
  
  it "prints its name for to_s" do
    name = 'test workspace'
    subject.name = name
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
  
  it "outputs its xml string" do
    pending
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
  
end