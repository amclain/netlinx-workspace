require 'rexml/document'
require 'netlinx/project'

module NetLinx
  
  # A NetLinx Studio workspace.
  # Collection of projects.
  # Workspace -> Project -> System
  class Workspace
    attr_accessor :name
    attr_accessor :description
    attr_accessor :projects
    
    def initialize(**kvargs)
      @name         = kvargs.fetch :name, ''
      @description  = kvargs.fetch :description, ''
      @projects     = []
      
      @file = kvargs.fetch :file, nil
      load_workspace @file if @file
    end
    
    # Alias to add a project.
    def <<(project)
      @projects << project
    end
    
    # Returns the name of the workspace.
    def to_s
      @name
    end
    
    private
    
    # Load the workspace from a given NetLinx Studio .apw file.
    def load_workspace(file)
      raise LoadError, "File does not exist at:\n#{file}" unless File.exists? file
      
      doc = nil
      File.open file, 'r' do |f|
        doc = REXML::Document.new f
      end
      
      # Load workspace params.
      @name        = doc.elements['/Workspace/Identifier'].text.strip
      @description = doc.elements['/Workspace/Comments'].text
      
      # Load projects.
      doc.each_element '/Workspace/Project' do |e|
        project = NetLinx::Project.new element: e
        @projects << project
      end
    end
    
  end
end