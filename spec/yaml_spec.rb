require 'netlinx/workspace/yaml'

describe NetLinx::Workspace::YAML do
  
  subject { NetLinx::Workspace::YAML }
  
  it { should respond_to :parse }
  it { should respond_to :parse_file }
  
  describe "parse" do
    subject { NetLinx::Workspace::YAML.parse_file 'workspace.config.yaml' }
    
    let(:workspace) { subject }
    
    def project
      workspace.projects.first
    end
    
    def system
      project.systems.first
    end
    
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
          
          file_list.should include 'module/duet-lib-pjlink_dr0_1_1.jar'
          file_list['module/duet-lib-pjlink_dr0_1_1.jar'].type.should eq :duet
          file_list['module/duet-lib-pjlink_dr0_1_1.jar'].name.should eq 'duet-lib-pjlink_dr0_1_1'
          
          file_list.should include 'module/tuner.tko'
          file_list['module/tuner.tko'].type.should eq :tko
          file_list['module/tuner.tko'].name.should eq 'tuner'
          
          file_list.should include 'module/video_wall.tko'
          file_list['module/video_wall.tko'].type.should eq :tko
          file_list['module/video_wall.tko'].name.should eq 'video_wall'
          
          file_list.should include 'module2/additional_module.tko'
          file_list['module2/additional_module.tko'].type.should eq :tko
          file_list['module2/additional_module.tko'].name.should eq 'additional_module'
          
          file_list.should include 'ir/Comcast,Comcast,xfinity,Unknown,1.irl'
          file_list['ir/Comcast,Comcast,xfinity,Unknown,1.irl'].tap do |file|
            file.type.should eq :ir
            file.devices.should eq ['5001:1:0']
          end
          
          file_list.should include 'ir/LG,LG,Unknown,Unknown,1.irl'
          file_list['ir/LG,LG,Unknown,Unknown,1.irl'].tap do |file|
            file.type.should eq :ir
            file.devices.should eq ['5001:2:0', '5001:3:0']
          end
          
          file_list.should include 'touch_panel/Admin iPad.TP4'
          file_list['touch_panel/Admin iPad.TP4'].tap do |file|
            file.type.should eq :tp4
            file.devices.should eq ['10001:1:0']
          end
          
          file_list.should include 'touch_panel/Conference Room Table.TP5'
          file_list['touch_panel/Conference Room Table.TP5'].tap do |file|
            file.type.should eq :tp5
            file.devices.should eq ['10002:1:0', '10003:1:0']
          end
          
          file_list.should include 'include2/matrix.axi'
          file_list['include2/matrix.axi'].type.should eq :include
          file_list['include2/matrix.axi'].name.should eq 'matrix'
          
          file_list.should_not include 'MyClient Conference Room.tko'
          file_list.should_not include 'MyClient Conference Room.tkn'
          file_list.should_not include 'exclude/do_not_include.axi'
          file_list.should_not include 'exclude/do_not_include.irl'
          file_list.should_not include 'exclude/do_not_include.TP4'
          file_list.should_not include 'include/excluded_file.axi'
          file_list.should_not include 'module/excluded_module.axs'
          file_list.should_not include 'module/excluded_module.tko'
          # Do not include source; modules must be compiled.
          file_list.should_not include 'module/tuner.axs'
          file_list.should_not include 'module/additional_module.axs'
        end
      end
      
      it "should automatically be active if it's the only system in the workspace" do
        system.active.should eq true
      end
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
          system.active.should eq false
          system.id.should eq 0
          system.description.should eq ''
          system.ip_address.should eq '192.168.1.2'
          system.ip_port.should eq 1319
          
          Hash[system.files.map { |f| [f.path, f] }].tap do |file_list|
            file_list.should include 'Production.axs'
            file_list['Production.axs'].type.should eq :master
            file_list['Production.axs'].name.should eq system.name
            
            file_list.should include 'include/audio.axi'
            file_list['include/audio.axi'].type.should eq :include
            file_list['include/audio.axi'].name.should eq 'audio'
            
            file_list.should include 'include/projector.axi'
            file_list['include/projector.axi'].type.should eq :include
            
            file_list.should include 'touch_panel/Production.TP4'
            file_list['touch_panel/Production.TP4'].tap do |file|
              file.type.should eq :tp4
              file.devices.should eq ['10001:1:0']
            end
          end
        end
        
        project.systems[1].tap do |system|
          system.name.should eq 'Test Suite'
          system.active.should eq true
          system.id.should eq 2
          system.description.should eq 'For testing code.'
          system.ip_address.should eq '192.168.253.2'
          system.ip_port.should eq 5000
          
          Hash[system.files.map { |f| [f.path, f] }].tap do |file_list|
            file_list.should include 'test_suite/Test Suite.axs'
            file_list['test_suite/Test Suite.axs'].type.should eq :master
            file_list['test_suite/Test Suite.axs'].name.should eq system.name
            
            file_list.should include 'test_suite/include/test_harness.axi'
            file_list['test_suite/include/test_harness.axi'].type.should eq :include
            file_list['test_suite/include/test_harness.axi'].name.should eq 'test_harness'
          end
        end
        
        project.systems[2].tap do |system|
          system.name.should eq 'Serial Connection 1'
          system.active.should eq false
          system.id.should eq 0
          system.description.should eq ''
          system.com_port.should eq :com5
          system.baud_rate.should eq 38400
          system.data_bits.should eq 8
          system.parity.should eq :none
          system.stop_bits.should eq 1
          
          Hash[system.files.map { |f| [f.path, f] }].tap do |file_list|
            file_list.should include 'serial_connection_1/Overridden File Name.axs'
            file_list['serial_connection_1/Overridden File Name.axs'].type.should eq :master
            file_list['serial_connection_1/Overridden File Name.axs'].name.should eq 'Overridden File Name'
            
            file_list.should_not include 'include/audio.axi'
            file_list.should_not include 'include/projector.axi'
          end
        end
        
        project.systems[3].tap do |system|
          system.name.should eq 'Serial Connection 2'
          system.active.should eq false
          system.id.should eq 0
          system.description.should eq ''
          system.com_port.should eq :com2
          system.baud_rate.should eq 57600
          system.data_bits.should eq 8
          system.parity.should eq :none
          system.stop_bits.should eq 1
          
          Hash[system.files.map { |f| [f.path, f] }].tap do |file_list|
            file_list.should include 'serial_connection_2/Serial Connection 2.axs'
            file_list['serial_connection_2/Serial Connection 2.axs'].type.should eq :master
            file_list['serial_connection_2/Serial Connection 2.axs'].name.should eq system.name
            
            file_list.should include 'serial_connection_2/touch_panel/Serial Connection 2.TP4'
            file_list['serial_connection_2/touch_panel/Serial Connection 2.TP4'].tap do |file|
              file.type.should eq :tp4
              file.devices.should eq ['10004:1:0']
            end
            
            file_list.should include 'serial_connection_2/ir/Serial Connection 2.irl'
            file_list['serial_connection_2/ir/Serial Connection 2.irl'].tap do |file|
              file.type.should eq :ir
              file.devices.should eq ['5004:1:0']
            end
            
            file_list.should_not include 'include/audio.axi'
            file_list.should_not include 'include/projector.axi'
          end
        end
        
        project.systems[4].tap do |system|
          system.name.should eq 'Serial Connection 3'
          system.active.should eq false
          system.id.should eq 0
          system.description.should eq ''
          system.com_port.should eq :com3
          system.baud_rate.should eq 115200
          system.data_bits.should eq 7
          system.parity.should eq :even
          system.stop_bits.should eq 2
          
          Hash[system.files.map { |f| [f.path, f] }].tap do |file_list|
            file_list.should include 'serial_connection_3/Serial Connection 3.axs'
            file_list['serial_connection_3/Serial Connection 3.axs'].type.should eq :master
            file_list['serial_connection_3/Serial Connection 3.axs'].name.should eq system.name
            
            file_list.should_not include 'include/audio.axi'
            file_list.should_not include 'include/projector.axi'
          end
        end
      end
    end
    
    describe "workspace" do
      let(:file) { 'workspace' }
      specify do
        workspace.name.should eq 'Workspace Config'
        workspace.description.should eq 'Workspace description.'
        
        workspace.projects.count.should eq 2
        
        workspace.projects[0].tap do |project|
          project.systems.count.should eq 2
          
          project.name.should           eq 'Production'
          project.description.should    eq 'Project description.'
          project.designer.should       eq 'Test Designer'
          project.dealer.should         eq '123'
          project.sales_order.should    eq '456'
          project.purchase_order.should eq '789'
          
          project.systems[0].tap do |system|
            system.name.should eq 'Room 101'
            system.active.should eq false
            system.id.should eq 0
            system.description.should eq ''
            system.ip_address.should eq '192.168.1.2'
            system.ip_port.should eq 1319
            
            Hash[system.files.map { |f| [f.path, f] }].tap do |file_list|
              file_list.should include 'room_101/Room 101.axs'
              file_list['room_101/Room 101.axs'].type.should eq :master
              file_list['room_101/Room 101.axs'].name.should eq system.name
              
              file_list.should include 'room_101/include/matrix.axi'
              file_list['room_101/include/matrix.axi'].type.should eq :include
              file_list['room_101/include/matrix.axi'].name.should eq 'matrix'
              
              file_list.should include 'room_101/touch_panel/Room_101.TP4'
              file_list['room_101/touch_panel/Room_101.TP4'].tap do |file|
                file.type.should eq :tp4
                file.devices.should eq ['10001:1:1']
              end
            end
          end
          
          project.systems[1].tap do |system|
            system.name.should eq 'Room 201'
            system.active.should eq false
            system.id.should eq 0
            system.description.should eq ''
            system.ip_address.should eq '192.168.1.3'
            system.ip_port.should eq 1319
            
            Hash[system.files.map { |f| [f.path, f] }].tap do |file_list|
              file_list.should include 'room_201/Room 201.axs'
              file_list['room_201/Room 201.axs'].type.should eq :master
              file_list['room_201/Room 201.axs'].name.should eq system.name
              
              file_list.should include 'room_201/include/switcher.axi'
              file_list['room_201/include/switcher.axi'].type.should eq :include
              file_list['room_201/include/switcher.axi'].name.should eq 'switcher'
              
              file_list.should include 'room_201/touch_panel/Room_201.TP4'
              file_list['room_201/touch_panel/Room_201.TP4'].tap do |file|
                file.type.should eq :tp4
                file.devices.should eq ['10002:1:2']
              end
            end
          end
          
          workspace.projects[1].tap do |project|
            project.systems.count.should eq 1
            
            project.name.should           eq 'Test Suite'
            project.description.should    eq ''
            project.designer.should       eq ''
            project.dealer.should         eq ''
            project.sales_order.should    eq ''
            project.purchase_order.should eq ''
            
            project.systems[0].tap do |system|
              system.name.should eq 'Test Suite'
              system.active.should eq true
              system.id.should eq 0
              system.description.should eq ''
              system.ip_address.should eq '192.168.253.2'
              system.ip_port.should eq 1319
              
              Hash[system.files.map { |f| [f.path, f] }].tap do |file_list|
                file_list.should include 'test_suite/Test Suite.axs'
                file_list['test_suite/Test Suite.axs'].type.should eq :master
                file_list['test_suite/Test Suite.axs'].name.should eq system.name
                
                file_list.should include 'test_suite/include/test_harness.axi'
                file_list['test_suite/include/test_harness.axi'].type.should eq :include
                file_list['test_suite/include/test_harness.axi'].name.should eq 'test_harness'
              end
            end
          end
          
        end
      end
    end
    
    describe "warn on nonexistent file" do
      let(:file) { 'warn_on_nonexistent_file' }
      let(:name) { 'Warn On Nonexistent File' }
      
      specify do
        $stdout.should_receive(:puts).exactly(3).times { |str|
          str.should start_with "WARNING: "
        }
        workspace.name.should eq name
      end
    end
  end
  
end
