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
    attr_reader   :file
    
    # Search backwards through directory tree and return the first workspace found.
    def self.search dir: nil
      dir ||= File.expand_path '.'
      while dir != File.expand_path('..', dir)
        workspaces = Dir["#{dir}/*.apw"]
        dir = File.expand_path('..', dir)
        next if workspaces.empty?
        
        return new file: workspaces.first
      end
      
      nil
    end
    
    # @option kwargs [String] :name ('') Workspace name.
    # @option kwargs [String] :description ('')
    def initialize **kwargs
      @name        = kwargs.fetch :name, ''
      @description = kwargs.fetch :description, ''
      @projects    = []
      
      @file = kwargs.fetch :file, nil
      load_workspace @file if @file
    end
    
    # Alias to add a project.
    def << project
      @projects << project
      project.workspace = self
    end
    
    # Returns the name of the workspace.
    def to_s
      @name
    end
    
    # Directory the workspace resides in.
    def path
      File.dirname @file if @file
    end
    
    # @return true if the workspace contains the specified file.
    def include? file
      included = false
      
      projects.each do |project|
        included = project.include? file
        break if included
      end
      
      included
    end
    
    # Compile all projects in this workspace.
    def compile
      compiler_results = []
      
      @projects.each do |project|
        project.compile.each {|result| compiler_results << result}
      end
      
      compiler_results
    end
    
    # @return [REXML::Element] an XML element representing this workspace.
    def to_xml_element
      REXML::Element.new('Workspace').tap do |workspace|
        workspace.attributes['CurrentVersion'] = '4.0'
        
        workspace.add_element('Identifier').tap { |e| e.text = name }
        workspace.add_element('CreateVersion').tap { |e| e.text = '4.0' }
        workspace.add_element('Comments').tap { |e| e.text = description }
        
        @projects.each { |project| workspace << project.to_xml_element }
      end
    end
    
    # @return [String] an XML string representing this workspace.
    # 
    # @todo REXML bug forces :indent to be -1 or else erroneous line feeds are added.
    def to_xml indent: -1
      str = '<?xml version="1.0" encoding="UTF-8"?>' + "\n"
      
      REXML::Document.new.tap do |doc|
        doc << to_xml_element
        doc.write output: str, indent: indent
      end
      
      str + "\n"
    end
    
    # Generate a {NetLinx::Workspace} from an XML string.
    # @return self
    def parse_xml string
      parse_xml_element REXML::Document.new(string)
      self
    end
    
    private
    
    # Load the workspace from a given NetLinx Studio .apw file.
    def load_workspace file
      raise LoadError, "File does not exist at:\n#{file}" unless File.exists? file
      
      doc = nil
      File.open file, 'r' do |f|
        doc = REXML::Document.new f
      end
      
      parse_xml_element doc
    end
    
    def parse_xml_element root
      # Load workspace params.
      @name        = root.elements['/Workspace/Identifier'].text.strip || ''
      @description = root.elements['/Workspace/Comments'].text || ''
        
      # Load projects.
      root.each_element '/Workspace/Project' do |e|
        project = NetLinx::Project.new \
          element:   e,
          workspace: self
          
        @projects << project
      end
    end
    
  end
end