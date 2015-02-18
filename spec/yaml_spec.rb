require 'netlinx/workspace/yaml'

describe NetLinx::Workspace::YAML do
  
  subject { NetLinx::Workspace::YAML }
  
  it { should respond_to :parse }
  it { should respond_to :parse_file }
  
  describe "parse" do
    subject { NetLinx::Workspace::YAML.parse_file "spec/workspace/yaml/config/#{file}" }
    let(:workspace) { subject }
    
    def project
      workspace.projects.first
    end
    
    def system
      project.systems.first
    end
    
    describe "single system" do
      let(:file) { 'single_system.yaml' }
      
      let(:name) { 'Client - Project' }
      
      specify do
        workspace.should be_a NetLinx::Workspace
        
        workspace.name.should eq name
        workspace.description.should eq ''
        
        workspace.projects.count.should eq 1
        project.name.should eq name
        project.description.should eq ''
        
        system.id.should eq 3
        system.description.should eq 'System description.'
        system.ip_address.should eq '192.168.1.2'
        system.ip_port.should eq 1319
      end
    end
    
    describe "multiple systems" do
      let(:file) { 'multiple_systems.yaml' }
      specify
    end
    
    describe "workspace" do
      let(:file) { 'workspace.yaml' }
      specify
    end
  end
  
end
