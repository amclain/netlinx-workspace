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
          
          parse_systems project, yaml_systems
        else
          # An explicit workspace is defined.
          workspace.name = yaml['name'] if yaml['name']
          workspace.description = yaml['description'] if yaml['description']
          
          yaml_projects = yaml['projects']
          yaml_projects.each do |yaml_project|
            workspace << NetLinx::Project.new.tap do |project|
              project.name           = yaml_project['name'] if yaml_project['name']
              project.designer       = yaml_project['designer'].to_s if yaml_project['designer']
              project.dealer         = yaml_project['dealer'].to_s if yaml_project['dealer']
              project.sales_order    = yaml_project['sales_order'].to_s if yaml_project['sales_order']
              project.purchase_order = yaml_project['purchase_order'].to_s if yaml_project['purchase_order']
              project.description    = yaml_project['description'] if yaml_project['description']
              
              parse_systems project, yaml_project['systems']
            end
          end
        end
        
        workspace.file = "#{workspace.name}.apw"
        
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
        workspace.projects.first.systems.first.active = true \
          unless a_system_is_active \
          or workspace.projects.empty? \
          or workspace.projects.first.systems.empty?
        
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
        return unless devices
        
        devices = [devices] unless devices.is_a? Array
        
        system_file.devices = devices.map do |d|
          # Convert to string if YAML parses the DPS as date/time.
          d.is_a?(String) ? d : [d / 3600, d % 3600 / 60, d % 60].join(':')
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
      
      def self.parse_systems project, yaml_systems
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
            include_files -= Dir[*yaml_excluded_files] if yaml_excluded_files
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
            
            # Auto-include 'module' directory.
            module_path = 'module/**/*.{tko,jar}'
            module_path = "#{root}/#{module_path}" if root
            module_files = Dir[module_path]
            module_files -= Dir[*yaml_excluded_files] if yaml_excluded_files
            module_files.each do |file_path|
              add_file_to_system system, file_path, 
                (File.extname(file_path) == '.jar') ?
                  :duet :
                  File.extname(file_path)[1..-1].downcase.to_sym
            end
            
            # Additional module paths.
            yaml_files = yaml_system['modules']
            if yaml_files
              files = Dir[*yaml_files]
              files -= Dir[*yaml_excluded_files] if yaml_excluded_files
              
              files.each do |file_path|
                add_file_to_system system, file_path, File.extname(file_path)[1..-1].downcase.to_sym
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
          end
        end
      end
      
    end
  end
end
