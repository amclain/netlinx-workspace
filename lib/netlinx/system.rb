require 'netlinx/system_file'

module NetLinx
  # A collection of resources loaded onto a NetLinx master.
  # Workspace -> Project -> System
  class System
    attr_accessor :name
    attr_accessor :id
    attr_accessor :description
    attr_accessor :project        # A reference to the system's parent project.
    attr_accessor :files
    
    def initialize(**kvargs)
      @name        = kvargs.fetch :name,        ''
      @id          = kvargs.fetch :id,          ''
      @description = kvargs.fetch :description, ''
      @project     = kvargs.fetch :project,     nil
      
      @files = []
      
      @compiler_target_files  = []
      @compiler_include_paths = []
      @compiler_module_paths  = []
      @compiler_library_paths = []
      
      system_element = kvargs.fetch :element, nil
      parse_xml_element system_element if system_element
    end
    
    # Alias to add a file.
    def <<(file)
      @files << file
      file.system = self
    end
    
    # Returns the system name.
    def to_s
      @name
    end
    
    # See Test::NetLinx::Compilable.
    def compiler_target_files
      @files
        .select {|f| f.type == 'MasterSrc'}
        .map {|f| File.expand_path \
          f.path,
          f.system.project.workspace.path
        }.uniq
    end
    
    # See Test::NetLinx::Compilable.
    def compiler_include_paths
      @files
        .select {|f| f.type == 'Include'}
        .map {|f| File.expand_path \
          File.dirname(f.path),
          f.system.project.workspace.path
        }.uniq
    end
    
    # See Test::NetLinx::Compilable.
    def compiler_module_paths
      @files
        .select {|f| f.type == 'Module' || f.type == 'TKO' || f.type == 'DUET'}
        .map {|f| File.expand_path \
          File.dirname(f.path),
          f.system.project.workspace.path
        }.uniq
    end
    
    # See Test::NetLinx::Compilable.
    def compiler_library_paths
      []
    end
    
    # Returns true if the project contains the specified file. 
    def include?(file)
      included = false
      
      @files.each do |f|
        name_included = f.name.downcase.eql? file.downcase
        
        # TODO: This should probably be relative to the workspace path,
        #       which can be found by traversing @project, @workspace.
        path_included = file.gsub(/\\/, '/').include? f.path.gsub(/\\/, '/')
        
        included = name_included || path_included
        break if included
      end
      
      included
    end
    
    # Compile this system.
    def compile
      # The compiler dependency is only needed if this method is called.
      require 'netlinx/compiler'
      
      compiler = NetLinx::Compiler.new
      compiler.compile self
    end
    
    private
    
    def parse_xml_element(system)
      # Load system params.
      @name        = system.elements['Identifier'].text.strip
      @id          = system.elements['SysID'].text.strip.to_i
      @description = system.elements['Comments'].text
      
      # Create system files.
      system.each_element 'File' do |e|
        system_file = NetLinx::SystemFile.new \
          element: e,
          system:  self
        
        @files << system_file
      end
    end
    
  end
end