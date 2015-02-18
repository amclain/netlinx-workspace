require 'rexml/document'
require_relative 'system'

module NetLinx
  # A collection of NetLinx systems.
  # Workspace -> Project -> System
  class Project
    # A reference to the project's parent workspace.
    attr_accessor :workspace
    attr_accessor :name
    attr_accessor :description
    attr_accessor :dealer
    attr_accessor :designer
    attr_accessor :sales_order
    attr_accessor :purchase_order
    attr_accessor :systems
    
    # @option kwargs [NetLinx::Workspace] :workspace This system's parent workspace node.
    # @option kwargs [String] :name ('') Project name.
    # @option kwargs [String] :description ('')
    # @option kwargs [String] :dealer ('')
    # @option kwargs [String] :designer ('')
    # @option kwargs [String] :sales_order ('')
    # @option kwargs [String] :purchase_order ('')
    def initialize **kwargs
      @workspace      = kwargs.fetch :workspace,      nil
      
      @name           = kwargs.fetch :name,           ''
      @description    = kwargs.fetch :description,    ''
      @dealer         = kwargs.fetch :dealer,         ''
      @designer       = kwargs.fetch :designer,       ''
      @sales_order    = kwargs.fetch :sales_order,    ''
      @purchase_order = kwargs.fetch :purchase_order, ''
      
      @systems = []
      
      project_element = kwargs.fetch :element, nil
      parse_xml_element project_element if project_element
    end
    
    # Alias to add a system.
    def << system
      @systems << system
      system.project = self
    end
    
    # @return the project name.
    def to_s
      @name
    end
    
    # @return true if the project contains the specified file.
    def include? file
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
    
    # @return [REXML::Element] an XML element representing this project.
    def to_xml_element
      REXML::Element.new('Project').tap do |project|
        project.add_element('Identifier').tap { |e| e.text = name }
        project.add_element('Designer').tap { |e| e.text = designer }
        project.add_element('DealerID').tap { |e| e.text = dealer }
        project.add_element('SalesOrder').tap { |e| e.text = sales_order }
        project.add_element('PurchaseOrder').tap { |e| e.text = purchase_order }
        project.add_element('Comments').tap { |e| e.text = description }
        
        @systems.each { |system| project << system.to_xml_element }
      end
    end
    
    private
    
    def parse_xml_element project
      # Load project params.
      @name           = project.elements['Identifier'].text.strip || ''
      @designer       = project.elements['Designer'].text || ''
      @dealer         = project.elements['DealerID'].text || ''
      @sales_order    = project.elements['SalesOrder'].text || ''
      @purchase_order = project.elements['PurchaseOrder'].text || ''
      @description    = project.elements['Comments'].text || ''
        
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