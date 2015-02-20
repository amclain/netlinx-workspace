require 'rake'
require 'rake/tasklib'

module NetLinx
  module Rake
    module Workspace
      
      # Create a workspace config.yaml file.
      class CreateWorkspaceConfig < ::Rake::TaskLib
        
        attr_accessor :name
        
        def initialize name = :create_workspace_config
          @name = name
          yield self if block_given?
          
          desc "Create a workspace config.yaml file."
          
          task(name) do
            config_file = 'workspace.config.yaml'
            
            if File.exists? config_file
              puts "Aborted: #{config_file} already exists."
              next
            end
            
            File.open config_file, 'w' do |f|
              f.write <<EOS
systems:
  -
    name: Client - Room
    connection: 192.168.1.2
    touch_panels:
      -
        path: Touch Panel.TP4
        dps: '10001:1:0'
    ir:
      -
        path: IR.irl
        dps: '5001:1:0'
EOS
            end
          end
        end
        
      end
    end
  end
end
