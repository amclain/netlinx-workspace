require 'netlinx/project'

describe NetLinx::Project do
  
  it "has a name" do
    name = 'import-test-project'
    subject.name = name
    subject.name.should eq name
  end
  
  it "has a dealer" do
    dealer = 'Test Dealer'
    subject.dealer = dealer
    subject.dealer.should eq dealer
  end
  
  it "has a designer" do
    designer = 'Test Designer'
    subject.designer = designer
    subject.designer.should eq designer
  end
  
  it "has a sales order field" do
    sales_order = 'Test Sales Order'
    subject.sales_order = sales_order
    subject.sales_order.should eq sales_order
  end
  
  it "has a purchase order field" do
    purchase_order = 'Test Purchase Order'
    subject.purchase_order = purchase_order
    subject.purchase_order.should eq purchase_order
  end
  
  it "has a description" do
    description = 'Test Description'
    subject.description = description
    subject.description.should eq description
  end
  
  it "contains systems" do
    subject.systems.should eq []
  end
  
  it "prints its name for to_s" do
    name = 'project name'
    subject.name = name
    subject.to_s.should eq name
  end
  
  it "can add a system with <<" do
    system = NetLinx::System.new
    subject << system
    subject.systems.first.should eq system
    system.project.should eq subject
  end
  
  it "stores a reference to its parent workspace" do
    subject.should respond_to :workspace
  end
  
  it "can invoke the compiler on itself" do
    subject.should respond_to :compile
  end
  
  it "can check if a file is included in the project" do
    subject.should respond_to :include?
  end
  
  describe "xml output" do
    subject {
      NetLinx::Project.new(
        name: name,
        description: description,
        dealer: dealer,
        designer: designer,
        sales_order: sales_order,
        purchase_order: purchase_order
      ).tap { |p| p << system }
    }
    
    let(:element) { subject.to_xml_element }
    
    let(:system) { NetLinx::System.new name: system_name }
    let(:system_name) { 'Test System' }
    
    let(:name)           { 'Test Project' }
    let(:description)    { 'Project description.' }
    let(:dealer)         { 'Project Dealer' }
    let(:designer)       { 'Project Designer' }
    let(:sales_order)    { 'Sales Order' }
    let(:purchase_order) { 'Purchase Order' }
    
    it { should respond_to :to_xml_element }
    
    specify do
      element.should be_a REXML::Element
      
      element.name.should eq 'Project'
      
      element.elements['Identifier'].first.should eq name
      element.elements['Designer'].first.should eq designer
      element.elements['DealerID'].first.should eq dealer
      element.elements['SalesOrder'].first.should eq sales_order
      element.elements['PurchaseOrder'].first.should eq purchase_order
      element.elements['Comments'].first.should eq description
      
      element.elements['System/Identifier'].first.should eq system_name
    end
  end
  
end