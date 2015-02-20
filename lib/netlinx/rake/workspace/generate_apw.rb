require 'rake'
require 'rake/tasklib'

module NetLinx
  module Rake
    module Workspace
      
      # Generate .apw workspace file from yaml config.
      class GenerateAPW < ::Rake::TaskLib
        
        attr_accessor :name
        
        def initialize name = :generate_apw
          @name = name
          yield self if block_given?
          
          desc "Generate .apw workspace file from yaml config."
          
          task(name) do
            require 'netlinx/workspace'
            
            NetLinx::Workspace::YAML.parse_file('workspace.config.yaml').tap do |workspace|
              return unless workspace.name
              File.open("#{workspace.name.strip}.apw", 'w') do |f|
                f.write workspace.to_xml
              end
            end
          end
        end
        
      end
    end
  end
end
