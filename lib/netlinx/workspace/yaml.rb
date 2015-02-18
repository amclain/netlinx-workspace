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
            NetLinx::System.new.tap do |system|
              system.name = yaml_system['name']
              system.id = yaml_system['id']
              system.description = yaml_system['description']
              
              connection = yaml_system['connection']
              if connection
                ip_address, ip_port = connection.split(':')
                system.ip_address = ip_address
                system.ip_port = ip_port if ip_port
              end
              
              project << system
            end
          end
        else
          # An explicit workspace is defined.
        end
        
        workspace
      end
      
      # @return {NetLinx::Workspace}
      def self.parse_file file
        parse File.open(file, 'r').read
      end
      
    end
  end
end
