require 'yaml'

module NetLinx
  class Workspace
    # Configure NetLinx workspaces with YAML.
    class YAML
      
      # @return {NetLinx::Workspace}
      def self.parse string
        yaml = ::YAML.load string
        yaml_systems = yaml['systems']
        
        workspace = NetLinx::Workspace.new
        
        if yaml_systems
          # Load systems into an implicit project and workspace.
          workspace.name = yaml_systems.first['name']
          project = NetLinx::Project.new name: yaml_systems.first['name']
          workspace << project
          
          yaml_systems.each do |yaml_system|
            project << NetLinx::System.new.tap do |system|
              system.name = yaml_system['name'] if yaml_system['name']
              system.active = yaml_system['active'] || false
              system.id = yaml_system['id'] if yaml_system['id']
              system.description = yaml_system['description'] if yaml_system['description']
              
              root = yaml_system['root'] # File system root directory.
              
              parse_connection_node system, yaml_system['connection']
              
              # Auto-include master source file.
              master_src_path = yaml_system['axs'] || "#{system.name}.axs"
              master_src_path = "#{root}/#{master_src_path}" if root
              add_file_to_system system, master_src_path, :master
              
              yaml_excluded_files = yaml_system['excluded_files']
              
              # Auto-include 'include' directory.
              include_path = 'include/**/*.axi'
              include_path = "#{root}/#{include_path}" if root
              include_files = Dir[include_path]
              include_files -= yaml_excluded_files if yaml_excluded_files
              include_files.each do |file_path|
                add_file_to_system system, file_path, :include
              end
              
              # Additional include paths.
              yaml_files = yaml_system['includes']
              if yaml_files
                files = Dir[*yaml_files]
                files -= Dir[*yaml_excluded_files] if yaml_excluded_files
                
                files.each do |file_path|
                  add_file_to_system system, file_path, :include
                end
              end
              
              # Touch panel files.
              yaml_touch_panels = yaml_system['touch_panels']
              if yaml_touch_panels
                yaml_touch_panels.each do |yaml_touch_panel|
                  file_path = "touch_panel/#{yaml_touch_panel['path']}"
                  file_path = "#{root}/#{file_path}" if root
                  add_file_to_system(system, file_path, File.extname(file_path)[1..-1].downcase.to_sym)
                    .tap { |file| attach_devices file, yaml_touch_panel }
                end
              end
              
              # IR files.
              yaml_ir_files = yaml_system['ir']
              if yaml_ir_files
                yaml_ir_files.each do |yaml_ir|
                  file_path = "ir/#{yaml_ir['path']}"
                  file_path = "#{root}/#{file_path}" if root
                  add_file_to_system(system, file_path, :ir)
                    .tap { |file| attach_devices file, yaml_ir }
                end
              end
              
              # TODO: Modules.
            end
          end
        else
          # An explicit workspace is defined.
        end
        
        # Ensure exactly one system in the workspace is set active.
        a_system_is_active = false
        workspace.projects.each do |project|
          project.systems.each do |system|
            if a_system_is_active
              system.active = false
              next
            else
              a_system_is_active = true if system.active
            end
          end
        end
        
        # No active systems. Set the first one active automatically.
        workspace.projects.first.systems.first.active = true unless a_system_is_active
        
        workspace
      end
      
      # @return {NetLinx::Workspace}
      def self.parse_file file
        parse File.open(file, 'r').read
      end
      
      private
      
      # @return [String] File name without the path or extension.
      def self.to_file_name path
        File.basename(path).gsub(/\.\w+\z/, '')
      end
      
      def self.add_file_to_system system, file_path, type
        puts "WARNING: Nonexistent file #{file_path}" unless File.exists? file_path
        
        NetLinx::SystemFile.new(
          path: file_path,
          name: to_file_name(file_path),
          type: type
        ).tap { |system_file| system << system_file }
      end
      
      def self.attach_devices system_file, yaml_node
        devices = yaml_node['dps']
        
        case devices
        when String
          system_file.devices = [devices]
        when Array
          system_file.devices = devices
        end
      end
      
      def self.parse_connection_node system, connection_node
        case connection_node
        when String
          if connection_node =~ /\Acom\d+(?::|\z)/i
            # Serial Connection
            com_port, baud_rate = connection_node.split ':'
            system.com_port = com_port.downcase.to_sym
            system.baud_rate = baud_rate.to_i if baud_rate
          else
            # IP Connection
            ip_address, ip_port = connection_node.split ':'
            system.ip_address = ip_address
            system.ip_port = ip_port.to_i if ip_port
          end
        when Hash
          if connection_node['host']
            # IP Connection
            system.ip_address = connection_node['host']
            system.ip_port = connection_node['port'] if connection_node['port']
          else
            # Serial Connection
            system.com_port = connection_node['port'].downcase.to_sym
            system.baud_rate = connection_node['baud_rate'] if connection_node['baud_rate']
            system.data_bits = connection_node['data_bits'] if connection_node['data_bits']
            system.stop_bits = connection_node['stop_bits'] if connection_node['stop_bits']
            system.parity = connection_node['parity'].downcase.to_sym if connection_node['parity']
          end
        end
      end
      
    end
  end
end
