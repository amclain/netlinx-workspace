require 'netlinx/system'

module NetLinx
  # A collection of NeTLinx systems.
  # Workspace -> Project -> System
  class Project
    attr_accessor :name
    attr_accessor :description
    attr_accessor :dealer
    attr_accessor :designer
    attr_accessor :sales_order
    attr_accessor :purchase_order
    attr_accessor :workspace        # A reference to the project's parent workspace.
    attr_accessor :systems
    
    def initialize(**kvargs)
      @name           = kvargs.fetch :name,           ''
      @description    = kvargs.fetch :description,    ''
      @dealer         = kvargs.fetch :dealer,         ''
      @designer       = kvargs.fetch :designer,       ''
      @sales_order    = kvargs.fetch :sales_order,    ''
      @purchase_order = kvargs.fetch :purchase_order, ''
      @workspace      = kvargs.fetch :workspace,      nil
      
      @systems = []
      
      project_element = kvargs.fetch :element, nil
      parse_xml_element project_element if project_element
    end
    
    # Alias to add a system.
    def <<(system)
      @systems << system
      system.project = self
    end
    
    # Returns the project name.
    def to_s
      @name
    end
    
    # Returns true if the project contains the specified file.
    def include?(file)
      included = false
      
      systems.each do |system|
        included = system.include? file
        break if included
      end
      
      included
    end
    
    # Compile all systems in this project.
    def compile
      compiler_results = []
      @systems.each {|system| compiler_results << (system.compile).first}
      compiler_results
    end
    
    private
    
    def parse_xml_element(project)
      # Load project params.
      @name           = project.elements['Identifier'].text.strip
      @designer       = project.elements['Designer'].text
      @dealer         = project.elements['DealerID'].text
      @sales_order    = project.elements['SalesOrder'].text
      @purchase_order = project.elements['PurchaseOrder'].text
      @description    = project.elements['Comments'].text
        
      # Load systems.
      project.each_element 'System' do |e|
        system = NetLinx::System.new \
          element: e,
          project:  self
          
        @systems << system
      end
    end
    
  end
end