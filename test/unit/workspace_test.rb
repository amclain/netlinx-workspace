require 'test_helper'
require 'netlinx/workspace'

describe NetLinx::Workspace do
  
  before do
    @workspace = @object = NetLinx::Workspace.new
    @workspace_path = 'test/unit/workspace/import-test'
  end
  
  after do
    @workspace = @object = nil
  end
  
  it "has a name" do
    name = 'my workspace'
    @workspace.name = name
    @workspace.name.must_equal name
  end
  
  it "has a description" do
    description = 'test description'
    @workspace.description = description
    @workspace.description.must_equal description
  end
  
  it "contains projects" do
    @workspace.projects.must_equal []
  end
  
  it "prints its name for to_s" do
    name = 'test workspace'
    @workspace.name = name
    @workspace.to_s.must_equal name
  end
  
  it "can add a project with <<" do
    project = NetLinx::Project.new
    @workspace << project
    @workspace.projects.first.must_equal project
  end
  
  it "exposes a directory path that the workspace resides in" do
    @workspace = NetLinx::Workspace.new \
      file: File.expand_path('import-test.apw', @workspace_path)
      
    @workspace.path.must_equal File.dirname(File.expand_path('import-test.apw', @workspace_path))
  end
  
  it "exposes the path to the .apw workspace file" do
    @workspace = NetLinx::Workspace.new \
      file: File.expand_path('import-test.apw', @workspace_path)
      
    @workspace.file.must_equal File.expand_path('import-test.apw', @workspace_path)
  end
  
  it "can be initialized from a .axw file" do
    # Import the test project.
    @workspace = NetLinx::Workspace.new \
      file: File.expand_path('import-test.apw', @workspace_path)
      
    @workspace.name.must_equal    'import-test'
    @workspace.description.must_equal 'For testing Ruby import.'
    
    # Check project data.
    @workspace.projects.count.must_equal 1
    project = @workspace.projects.first
    
    project.name.must_equal           'import-test-project'
    project.dealer.must_equal         'Test Dealer'
    project.designer.must_equal       'Test Designer'
    project.sales_order.must_equal    'Test Sales Order'
    project.purchase_order.must_equal 'Test PO'
    project.description.must_equal    'Test project description.'
    
    # Check system data.
    project.systems.count.must_equal 1
    system = project.systems.first
    
    system.name.must_equal        'import-test-system'
    system.id.must_equal          0
    system.description.must_equal 'Test system description.'
    
    # Contains the MasterSrc file to be compiled.
    assert system.compiler_target_files.include?(
      File.expand_path('import-test.axs', @workspace_path)
      ), "Contains the MasterSrc file to be compiled."
    
    # Contains include paths.
    assert system.compiler_include_paths.include?(
      File.expand_path('include', @workspace_path)
      ), "Contains source code include path."
    
    # Contains module paths.
    assert system.compiler_module_paths.include?(
      File.expand_path('duet-module', @workspace_path)
      ), "Contains duet module path."
    
    assert system.compiler_module_paths.include?(
      File.expand_path('module-compiled', @workspace_path)
      ), "Contains compiled module path."
    
    assert system.compiler_module_paths.include?(
      File.expand_path('module-source', @workspace_path)
      ), "Contains source code module path."
  end
  
  it "outputs its xml string" do
    skip
  end
  
  it "can invoke the compiler on itself" do
    assert_respond_to @workspace, :compile
  end
  
  it "can check if a file is included in the workspace" do
    @workspace = NetLinx::Workspace.new \
      file: File.expand_path('import-test.apw', @workspace_path)
    
    assert_respond_to @workspace, :include?
    
    @workspace.include?('import-test.axs').must_equal true,
      'Can find file by relative path.'
      
    @workspace.include?(File.expand_path('include/import-include.axi', @workspace_path)).must_equal true,
      'Can find file by absolute path.'
    
    @workspace.include?('import-test').must_equal true,
      'Can find file by element name.'
      
    @workspace.include?('does-not-exist').must_equal false,
      'Returns false for an element name that doesn\'t exist.'
    
    @workspace.include?('does-not-exist.axs').must_equal false,
      'Returns false for a relative path that doesn\'t exist.'
    
    @workspace.include?(File.expand_path('does-not-exist.axi', @workspace_path)).must_equal false,
      'Returns false for an absolute path that doesn\'t exist.'
  end
  
end