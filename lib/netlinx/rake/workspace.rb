require_relative 'workspace/create_workspace_config'
require_relative 'workspace/generate_apw'

module NetLinx
  # :nodoc:
  module Rake
    # NetLinx Workspace rake tasks.
    module Workspace
    end
  end
end

NetLinx::Rake::Workspace::CreateWorkspaceConfig.new
NetLinx::Rake::Workspace::GenerateAPW.new
