require 'rexml/document'

module NetLinx
  # A file node in a NetLinx::System.
  class SystemFile
    attr_accessor :system
    attr_accessor :name
    attr_accessor :path
    attr_accessor :description
    attr_accessor :type
    
    # @option kwargs [NetLinx::System] :system This file's parent system node.
    # @option kwargs [String] :name ('') Identifiable name.
    # @option kwargs [String] :path ('') Relative file path.
    # @option kwargs [String] :description ('')
    # @option kwargs [:master,:source,:include,:duet,:tko,:module,:ir,:tp4,:tp5] :type (:master)
    def initialize(**kvargs)
      @system      = kvargs.fetch :system,      nil
      
      @name        = kvargs.fetch :name,        ''
      @path        = kvargs.fetch :path,        ''
      @description = kvargs.fetch :description, ''
      @type        = kvargs.fetch :type,        :master
      
      system_file_element = kvargs.fetch :element, nil
      parse_xml_element system_file_element if system_file_element
    end
    
    # @return the SystemFile's name.
    def to_s
      @name
    end
    
    # @return an XML element representing this file.
    def to_xml_element
      REXML::Element.new('File').tap do |file|
        file.attributes['CompileType'] = 'Netlinx'
        
        file.attributes['Type'] = {
          master:  'MasterSrc',
          source:  'Source',
          include: 'Include',
          duet:    'DUET',
          tko:     'TKO',
          module:  'Module',
          ir:      'IR',
          tp4:     'TP4',
          tp5:     'TP5',
        }[type]
        
        file.add_element('Identifier').tap { |e| e.text = name }
        file.add_element('FilePathName').tap { |e| e.text = path }
        file.add_element('Comments').tap { |e| e.text = description }
      end
    end
    
    private
    
    def parse_xml_element(system_file)
      # Load system file params.
      @name        = system_file.elements['Identifier'].text.strip
      @type        = system_file.attributes['Type']
      @path        = system_file.elements['FilePathName'].text.strip
      @description = system_file.elements['Comments'].text
    end
    
  end
end