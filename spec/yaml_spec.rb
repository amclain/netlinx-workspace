require 'netlinx/workspace/yaml'

describe NetLinx::Workspace::YAML do
  
  subject { NetLinx::Workspace::YAML }
  
  it { should respond_to :parse }
  it { should respond_to :parse_file }
  
  describe "parse" do
    subject { NetLinx::Workspace::YAML.parse_file "#{file}.config.yaml" }
    
    let(:workspace) { subject }
    
    def project
      workspace.projects.first
    end
    
    def system
      project.systems.first
    end
    
    before { workspace.should be_a NetLinx::Workspace }
    
    around { |test| Dir.chdir("spec/workspace/yaml/#{file}") { test.run } }
    
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
        
        Hash[system.files.map { |f| [f.path, f] }].tap do |file_list|
          file_list.should include 'MyClient Conference Room.axs'
          file_list['MyClient Conference Room.axs'].type.should eq :master
          file_list['MyClient Conference Room.axs'].name.should eq system.name
          
          file_list.should include 'include/audio.axi'
          file_list['include/audio.axi'].type.should eq :include
          file_list['include/audio.axi'].name.should eq 'audio'
          file_list.should include 'include/projector.axi'
          file_list['include/projector.axi'].type.should eq :include
          file_list.should include 'ir/Comcast,Comcast,xfinity,Unknown,1.irl'
          file_list['ir/Comcast,Comcast,xfinity,Unknown,1.irl'].type.should eq :ir
          file_list.should include 'ir/LG,LG,Unknown,Unknown,1.irl'
          file_list['ir/LG,LG,Unknown,Unknown,1.irl'].type.should eq :ir
          file_list.should include 'touch_panel/Admin iPad.TP4'
          file_list['touch_panel/Admin iPad.TP4'].type.should eq :tp4
          file_list.should include 'touch_panel/Conference Room Table.TP5'
          file_list['touch_panel/Conference Room Table.TP5'].type.should eq :tp5
          
          file_list.should include 'include2/matrix.axi'
          file_list['include/audio.axi'].type.should eq :include
          file_list['include/audio.axi'].name.should eq 'matrix'
          
          file_list.should_not include 'MyClient Conference Room.tko'
          file_list.should_not include 'MyClient Conference Room.tkn'
          file_list.should_not include 'exclude/do_not_include.axi'
          file_list.should_not include 'exclude/do_not_include.irl'
          file_list.should_not include 'exclude/do_not_include.TP4'
          file_list.should_not include 'include/excluded_file.axi'
        end
      end
      
      specify "device mapping"
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
      specify "device mapping"
    end
    
    describe "workspace" do
      let(:file) { 'workspace' }
      specify
      specify "test included files"
      specify "device mapping"
    end
  end
  
end
