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
            # TODO: Implement.
            raise NotImplementedError
          end
        end
        
      end
    end
  end
end
