require 'netlinx/compiler'
require 'netlinx/workspace'

module NetLinx
  module Compile
    module Extension
      # Instructs netlinx-compile on how to process .apw NetLinx source code files.
      class APW
        def invoke_compile(**kvargs)
          target = kvargs.fetch(:target, nil)
          raise ArgumentError, "Invalid workspace: #{target}." unless target
          
          compiler_results = []
          
          workspace = NetLinx::Workspace.new \
            file: target
          
          # -----------------------------------------------
          # TODO: This should be delegated under Workspace.
          # -----------------------------------------------
          workspace.projects.each do |project|
            project.systems.each do |system|
              @compiler = NetLinx::Compiler.new
              compiler_results << (@compiler.compile system).first
            end
          end
          
          compiler_results
        end
      end
    end
  end
end