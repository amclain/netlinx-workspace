require 'rexml/document'
require_relative 'system_file'

module NetLinx
  # A collection of resources loaded onto a NetLinx master.
  # Workspace -> Project -> System
  class System
    # A reference to the system's parent project.
    attr_accessor :project
    attr_accessor :files
    
    attr_accessor :name
    attr_accessor :active
    attr_accessor :id
    attr_accessor :description
    
    attr_accessor :ip_address
    attr_accessor :ip_port
    attr_accessor :ensure_availability
    
    attr_accessor :com_port
    attr_accessor :baud_rate
    attr_accessor :data_bits
    attr_accessor :parity
    attr_accessor :stop_bits
    attr_accessor :flow_control
    
    # @option kwargs [NetLinx::Project] :project This system's parent project node.
    # @option kwargs [String] :name ('') System name.
    # @option kwargs [String] :description ('')
    # @option kwargs [Boolean] :active (false) True if this is the active system
    #   in the workspace.
    # @option kwargs [Integer] :id (0) Master controller system ID.
    #   0 connects to any master at the given communication settings.
    #   Or in other words, 0 prevents disconnection from a master
    #   with a different ID.
    # 
    # @option kwargs [String] :ip_address ('0.0.0.0')
    # @option kwargs [String] :ip_port (1319) ICSLan port.
    # @option kwargs [String] :ensure_availability (true) Ping the master
    #   controller to ensure availability before connecting.
    # 
    # @option kwargs [Symbol] :com_port (:com1)
    # @option kwargs [Integer] :baud_rate (38400)
    # @option kwargs [Integer] :data_bits (8)
    # @option kwargs [:none,:even,:odd,:mark,:space] :parity (:none)
    # @option kwargs [Integer] :stop_bits (1)
    # @option kwargs [:none] :flow_control (:none)
    def initialize **kwargs
      @project     = kwargs.fetch :project,     nil
      
      @name        = kwargs.fetch :name,        ''
      @id          = kwargs.fetch :id,          0
      @active      = kwargs.fetch :active,      false
      @description = kwargs.fetch :description, ''
      
      @ip_address  = kwargs.fetch :ip_address, '0.0.0.0'
      @ip_port     = kwargs.fetch :ip_port, 1319
      @ensure_availability = kwargs.fetch :ensure_availability, true
      
      @com_port     = kwargs.fetch :com_port,     :com1
      @baud_rate    = kwargs.fetch :baud_rate,    38400
      @data_bits    = kwargs.fetch :data_bits,    8
      @parity       = kwargs.fetch :parity,       :none
      @stop_bits    = kwargs.fetch :stop_bits,    1
      @flow_control = kwargs.fetch :flow_control, :none
      
      @files = []
      
      @compiler_target_files  = []
      @compiler_include_paths = []
      @compiler_module_paths  = []
      @compiler_library_paths = []
      
      system_element = kwargs.fetch :element, nil
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
    
    # @return [REXML::Element] an XML element representing this system.
    def to_xml_element
      REXML::Element.new('System').tap do |system|
        system.attributes['IsActive']  = active
        system.attributes['Platform']  = 'Netlinx'
        system.attributes['Transport'] = 'Serial'
        system.attributes['TransportEx'] =
          (ip_address == '0.0.0.0') ? 'Serial' : 'TCPIP'
        
        system.add_element('Identifier').tap { |e| e.text = name }
        system.add_element('SysID').tap { |e| e.text = id }
        system.add_element('Comments').tap { |e| e.text = description }
        
        # These don't seem to change in NetLinx Studio 4.0; possibly 3.x legacy.
        # The 'Ex' suffixes are used.
        system.add_element('TransTCPIP').tap { |e| e.text = '0.0.0.0' }
        system.add_element('TransSerial').tap { |e| e.text = 'COM1,38400,8,None,1,None' }
        
        # TODO: Generate communication settings.
        system.add_element('TransTCPIPEx').tap { |e|
          e.text = "#{ip_address}|#{ip_port}|#{ensure_availability ? 1 : 0}|||"
        }
        system.add_element('TransSerialEx').tap { |e|
          e.text = "#{com_port.upcase}|#{baud_rate}|#{data_bits}|#{parity.capitalize}|#{stop_bits}|||"
        }
        system.add_element('TransUSBEx').tap { |e| e.text = '|||||' }
        system.add_element('TransVNMEx').tap { |e| e.text = '||' }
        
        system.add_element('UserName').tap { |e| e.text = '' }
        system.add_element('Password').tap { |e| e.text = '' }
        
        @files.each { |file| system << file.to_xml_element }
      end
    end
    
    # @see Test::NetLinx::Compilable.
    def compiler_target_files
      @files
        .select {|f| f.type == :master}
        .map {|f| File.expand_path \
          f.path.gsub('\\', '/'),
          f.system.project.workspace.path
        }.uniq
    end
    
    # @see Test::NetLinx::Compilable.
    def compiler_include_paths
      @files
        .select {|f| f.type == :include}
        .map {|f| File.expand_path \
          File.dirname(f.path.gsub('\\', '/')),
          f.system.project.workspace.path
        }.uniq
    end
    
    # @see Test::NetLinx::Compilable.
    def compiler_module_paths
      @files
        .select {|f| f.type == :module || f.type == :tko || f.type == :duet}
        .map {|f| File.expand_path \
          File.dirname(f.path.gsub('\\', '/')),
          f.system.project.workspace.path
        }.uniq
    end
    
    # @see Test::NetLinx::Compilable.
    def compiler_library_paths
      []
    end
    
    # @return [Boolean] true if the project contains the specified file. 
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
      @name        = system.elements['Identifier'].text.strip || ''
      @active      = (system.attributes['IsActive'].strip == 'true') ? true : false
      @id          = system.elements['SysID'].text.strip.to_i || 0
      @description = system.elements['Comments'].text || ''
      
      if system.elements['TransTCPIPEx'] # Workspace v4.0
        tcpip = (system.elements['TransTCPIPEx'].text || '').split('|')
        
        @ip_address  = tcpip[0] || '0.0.0.0'
        @ip_port     = (tcpip[1] || 1319).to_i
        @ensure_availability = (tcpip[2] == '0') ? false : true
      end
      
      if system.elements['TransSerialEx'] # Workspace v4.0
        serial = (system.elements['TransSerialEx'].text || '').split('|')
        
        @com_port     = (serial[0] || :com1).to_s.downcase.to_sym
        @baud_rate    = (serial[1] || 38400).to_i
        @data_bits    = (serial[2] || 8).to_i
        @parity       = (serial[3] || :none).to_s.downcase.to_sym
        @stop_bits    = (serial[4] || 1).to_i
        @flow_control = (serial[5] || :none).to_s.downcase.to_sym
      end
      
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
