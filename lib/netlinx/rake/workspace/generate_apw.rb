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
            # TODO: Implement.
            raise NotImplementedError
          end
        end
        
      end
    end
  end
end
