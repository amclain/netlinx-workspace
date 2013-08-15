module NetLinx
  class SystemFile
    attr_accessor :name
    attr_accessor :type
    attr_accessor :path
    attr_accessor :description
    attr_accessor :system
    
    def initialize(**kvargs)
      @name        = kvargs.fetch :name,        ''
      @type        = kvargs.fetch :type,        ''
      @path        = kvargs.fetch :path,        ''
      @description = kvargs.fetch :description, ''
      @system      = kvargs.fetch :system,      nil
      
      system_file_element = kvargs.fetch :element, nil
      parse_xml_element system_file_element if system_file_element
    end
    
    # Print the SystemFile's name.
    def to_s
      @name
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