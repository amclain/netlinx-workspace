require 'netlinx/system_file'
require 'rexml/document'

module NetLinx
  # A collection of resources loaded onto a NetLinx master.
  # Workspace -> Project -> System
  class System
    attr_accessor :name
    attr_accessor :id
    attr_accessor :description
    attr_accessor :project        # A reference to the system's parent project.
    attr_accessor :files
    
    def initialize **kvargs
      @name        = kvargs.fetch :name,        ''
      @id          = kvargs.fetch :id,          0
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
    def << file
      @files << file
      file.system = self
    end
    
    # @return the system name.
    def to_s
      @name
    end
    
    # @return an XML element representing this system.
    def to_xml_element
      REXML::Element.new('System').tap do |system|
        system.attributes['IsActive']  = false
        system.attributes['Platform']  = 'Netlinx'
        system.attributes['Transport'] = 'Serial'
        system.attributes['TransportEx'] = 'TCPIP'
        
        system.add_element('Identifier').tap { |e| e.text = name }
        system.add_element('SysID').tap { |e| e.text = id }
        system.add_element('Comments').tap { |e| e.text = description }
        
        # These don't seem to change in NetLinx Studio 4.0; possibly 3.x legacy.
        # The 'Ex' suffixes are used.
        system.add_element('TransTCPIP').tap { |e| e.text = '0.0.0.0' }
        system.add_element('TransSerial').tap { |e| e.text = 'COM1,38400,8,None,1,None' }
        
        # TODO: Generate communication settings.
        system.add_element('TransTCPIPEx').tap { |e| e.text = '0.0.0.0|1319|1|||' }
        system.add_element('TransSerialEx').tap { |e| e.text = 'COM1|38400|8|None|1|||' }
        system.add_element('TransUSBEx').tap { |e| e.text = '|||||' }
        system.add_element('TransVNMEx').tap { |e| e.text = '||' }
        
        system.add_element('UserName').tap { |e| e.text = '' }
        system.add_element('Password').tap { |e| e.text = '' }
        
        # TODO: Add file elements.
      end
    end
    
    # @see Test::NetLinx::Compilable.
    def compiler_target_files
      @files
        .select {|f| f.type == 'MasterSrc'}
        .map {|f| File.expand_path \
          f.path.gsub('\\', '/'),
          f.system.project.workspace.path
        }.uniq
    end
    
    # @see Test::NetLinx::Compilable.
    def compiler_include_paths
      @files
        .select {|f| f.type == 'Include'}
        .map {|f| File.expand_path \
          File.dirname(f.path.gsub('\\', '/')),
          f.system.project.workspace.path
        }.uniq
    end
    
    # @see Test::NetLinx::Compilable.
    def compiler_module_paths
      @files
        .select {|f| f.type == 'Module' || f.type == 'TKO' || f.type == 'DUET'}
        .map {|f| File.expand_path \
          File.dirname(f.path.gsub('\\', '/')),
          f.system.project.workspace.path
        }.uniq
    end
    
    # @see Test::NetLinx::Compilable.
    def compiler_library_paths
      []
    end
    
    # Returns true if the project contains the specified file. 
    def include? file
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
    
    def parse_xml_element system
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
