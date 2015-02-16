require 'netlinx/compile/extension_handler'
require 'netlinx/workspace'

# :nodoc:
module NetLinx
  # :nodoc:
  module Compile
    # :nodoc:
    module Extension
      # Instructs netlinx-compile on how to process .apw NetLinx workspace files.
      class APW
        # :nodoc:
        def self.get_handler
          handler = NetLinx::Compile::ExtensionHandler.new \
            extensions:     ['apw'],
            is_a_workspace: true,
            handler_class:  NetLinx::Workspace
        end
      end
    end
  end
end