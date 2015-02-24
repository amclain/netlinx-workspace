require 'rexml/document'

module NetLinx
  # A file node in a NetLinx::System.
  class SystemFile
    attr_accessor :system
    attr_accessor :name
    attr_accessor :path
    attr_accessor :description
    attr_accessor :type
    # Array of D:P:S strings that this file maps to.
    attr_accessor :devices
    
    # @option kwargs [NetLinx::System] :system This file's parent system node.
    # @option kwargs [String] :name ('') Identifiable name.
    # @option kwargs [String] :path ('') Relative file path.
    # @option kwargs [String] :description ('')
    # @option kwargs [:master,:source,:include,:duet,:tko,:module,:ir,:tp4,:tp5] :type (:master)
    def initialize **kwargs
      @system      = kwargs.fetch :system,      nil
      
      @name        = kwargs.fetch :name,        ''
      @path        = kwargs.fetch :path,        ''
      @description = kwargs.fetch :description, ''
      @type        = kwargs.fetch :type,        :master
      
      @devices = []
      
      system_file_element = kwargs.fetch :element, nil
      parse_xml_element system_file_element if system_file_element
    end
    
    # Add a device that uses this file.
    # @param device [String] D:P:S string.
    def << device
      devices << device
    end
    
    # @return the SystemFile's name.
    def to_s
      @name
    end
    
    # @return [REXML::Element] an XML element representing this file.
    def to_xml_element
      REXML::Element.new('File').tap do |file|
        file.attributes['CompileType'] = 'Netlinx'
        
        file.attributes['Type'] = type_lookup[type]
        
        file.add_element('Identifier').tap { |e| e.text = name }
        file.add_element('FilePathName').tap { |e| e.text = path }
        file.add_element('Comments').tap { |e| e.text = description }
        
        @devices.each do |dps|
          file.add_element('DeviceMap').tap do |e|
            text = dps.include?(':') ? "Custom [#{dps}]" : dps
            e.attributes['DevAddr'] = text
            e.add_element('DevName').text = text
          end
        end
      end
    end
    
    private
    
    # @return lookup table for symbol to XML NetLinx file types.
    def type_lookup
      {
        master:  'MasterSrc',
        source:  'Source',
        include: 'Include',
        duet:    'DUET',
        tko:     'TKO',
        module:  'Module',
        ir:      'IR',
        tp4:     'TP4',
        tp5:     'TP5',
      }
    end
    
    def parse_xml_element system_file
      # Load system file params.
      @name        = system_file.elements['Identifier'].text.strip || ''
      @type        = type_lookup.invert[system_file.attributes['Type']] || :master
      @path        = system_file.elements['FilePathName'].text.strip || ''
      @description = system_file.elements['Comments'].text || ''
      
      system_file.each_element 'DeviceMap' do |device_map|
        dev_addr = device_map.attributes['DevAddr']
        @devices.push dev_addr.include?(':') ?
          dev_addr.match(/.*?\[(.*?)\]/)[1] :
          dev_addr
      end
    end
    
  end
end