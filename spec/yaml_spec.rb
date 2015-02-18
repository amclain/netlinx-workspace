require 'netlinx/workspace/yaml'

describe NetLinx::Workspace::YAML do
  
  subject { NetLinx::Workspace::YAML }
  
  it { should respond_to :parse }
  it { should respond_to :parse_file }
  
  describe "parse" do
    subject {
      NetLinx::Workspace::YAML.parse_file \
        "spec/workspace/yaml/#{file}/#{file}.config.yaml"
    }
    
    let(:workspace) { subject }
    
    def project
      workspace.projects.first
    end
    
    def system
      project.systems.first
    end
    
    before { workspace.should be_a NetLinx::Workspace }
    
    describe "single system" do
      let(:file) { 'single_system' }
      let(:name) { 'MyClient Conference Room' }
      
      specify do
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
      
      specify "test included files"
    end
    
    describe "multiple systems" do
      let(:file) { 'multiple_systems' }
      let(:name) { 'Production' }
      
      specify do
        workspace.name.should eq name
        workspace.description.should eq ''
        
        workspace.projects.count.should eq 1
        project.name.should eq name
        project.description.should eq ''
        
        project.systems[0].tap do |system|
          system.name.should eq name
          system.id.should eq 0
          system.description.should eq ''
          system.ip_address.should eq '192.168.1.2'
          system.ip_port.should eq 1319
        end
        
        project.systems[1].tap do |system|
          system.name.should eq 'Test Suite'
          system.id.should eq 2
          system.description.should eq 'For testing code.'
          system.ip_address.should eq '192.168.253.2'
          system.ip_port.should eq 5000
        end
        
        project.systems[2].tap do |system|
          system.name.should eq 'Serial Connection 1'
          system.id.should eq 0
          system.description.should eq ''
          system.com_port.should eq :com5
          system.baud_rate.should eq 38400
          system.data_bits.should eq 8
          system.parity.should eq :none
          system.stop_bits.should eq 1
        end
        
        project.systems[3].tap do |system|
          system.name.should eq 'Serial Connection 2'
          system.id.should eq 0
          system.description.should eq ''
          system.com_port.should eq :com2
          system.baud_rate.should eq 57600
          system.data_bits.should eq 8
          system.parity.should eq :none
          system.stop_bits.should eq 1
        end
        
        project.systems[4].tap do |system|
          system.name.should eq 'Serial Connection 3'
          system.id.should eq 0
          system.description.should eq ''
          system.com_port.should eq :com3
          system.baud_rate.should eq 115200
          system.data_bits.should eq 7
          system.parity.should eq :even
          system.stop_bits.should eq 2
        end
      end
      
      specify "test included files"
    end
    
    describe "workspace" do
      let(:file) { 'workspace' }
      specify
      specify "test included files"
    end
  end
  
end
