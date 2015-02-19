require 'netlinx/workspace/project'

describe NetLinx::Project do
  
  subject {
    NetLinx::Project.new \
      name: name,
      dealer: dealer,
      designer: designer,
      sales_order: sales_order,
      purchase_order: purchase_order,
      description: description
  }
  
  let(:name) { 'import-test-project' }
  let(:dealer) { 'Test Dealer' }
  let(:designer) { 'Test Designer' }
  let(:sales_order) { 'Test Sales Order' }
  let(:purchase_order) { 'Test Purchase Order' }
  let(:description) { 'Test Description' }
  
  its(:name) { should eq name }
  its(:dealer) { should eq dealer }
  its(:designer) { should eq designer }
  its(:sales_order) { should eq sales_order }
  its(:purchase_order) { should eq purchase_order }
  its(:description) { should eq description }
  
  it "contains systems" do
    subject.systems.should eq []
  end
  
  it "prints its name for to_s" do
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
    let(:element) { subject.to_xml_element }
    
    let(:system) { NetLinx::System.new name: system_name }
    let(:system_name) { 'Test System' }
    
    before { subject << system }
    
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