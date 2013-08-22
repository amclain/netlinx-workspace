require 'netlinx/compile/extension_handler'
require 'netlinx/workspace'

module NetLinx
  module Compile
    module Extension
      # Instructs netlinx-compile on how to process .apw NetLinx workspace files.
      class APW
        # :nodoc:
        def self.get_handler
          handler = NetLinx::Compile::ExtensionHandler.new \
            extensions: ['apw'],
            handler_class: NetLinx::Workspace
        end
      end
    end
  end
end