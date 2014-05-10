require 'netlinx/system'
require 'test/netlinx/compilable'
require 'ostruct'

describe NetLinx::System do
  
  subject { NetLinx::System.new project: project }
  
  let(:workspace) { OpenStruct.new path: File.expand_path('spec/workspace/import-test') }
  let(:project)   { OpenStruct.new workspace: workspace }
  
  
  describe "is compilable" do
    
    
    describe "interface" do
      # Converted from Test::NetLinx::Compilable
      # https://github.com/amclain/netlinx-compile/blob/master/lib/test/netlinx/compilable.rb
      
      specify "implements methods" do
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
      file = OpenStruct.new \
        type: 'MasterSrc',
        name: 'import-test',
        path: 'import-test.axs',
        system: subject
      
      subject << file
      subject.compiler_target_files.count.should eq 1
      subject.compiler_target_files.should include \
        File.expand_path('import-test.axs', workspace.path)
    end
    
    it "lists .axi file paths under include paths" do
      file = OpenStruct.new \
        type: 'Include',
        name: 'import-include',
        path: 'include\import-include.axi',
        system: subject
      
      subject << file
      subject.compiler_include_paths.should include \
        File.expand_path('include', workspace.path)
    end
    
    it "lists source, compiled, and duet modules under module paths" do
      source_module = OpenStruct.new \
        type: 'Module',
        name: 'test-module-source',
        path: 'module-source\test-module-source.axs',
        system: subject
        
      compiled_module = OpenStruct.new \
        type: 'TKO',
        name: 'test-module-compiled',
        path: 'module-compiled\test-module-compiled.tko',
        system: subject
        
      duet_module = OpenStruct.new \
        type: 'DUET',
        name: 'duet-lib-pjlink_dr0_1_1',
        path: 'duet-module\duet-lib-pjlink_dr0_1_1.jar',
        system: subject
      
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
  
  describe "stores project data" do
    it "has a name" do
      name = 'import-test-system'
      subject.name = name
      subject.name.should eq name
    end
    
    it "has a system ID" do
      id = 5
      subject.id = id
      subject.id.should eq id
    end
    
    it "has a description" do
      description = 'Test system description.'
      subject.description = description
      subject.description.should eq description
    end
    
    it "has files" do
      subject.files.should eq []
    end
    
    it "has communication settings" do
      pending
    end
  end
  
  it "outputs its name for to_s" do
    name = 'system name'
    subject.name = name
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
    
    file = OpenStruct.new \
      type: 'Include',
      name: 'import-include',
      path: 'include\import-include.axi',
      system: subject
    
    subject << file
    
    subject.should include 'import-include'
    subject.should include 'include\import-include.axi'
    subject.should_not include 'does-not-exist'
    subject.should_not include 'include\does-not-exist.axi'
  end
  
  describe "xml output" do
    it "needs to be implemented" do
      pending
    end
  end
end