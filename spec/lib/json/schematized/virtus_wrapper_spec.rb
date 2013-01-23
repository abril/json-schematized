require "spec_helper"

class VPerson
  include JSON::Schematized
  json_schema :wrapper => :virtus do
    YAML.load(File.read(File.expand_path("../../../../fixtures/person.yml", __FILE__)))["person"]
  end
end

describe ::JSON::Schematized::VirtusWrapper do
  let(:schema_fixture_file){ File.expand_path("../../../../fixtures/person.yml", __FILE__) }
  let(:schema_str){ MultiJson.dump(YAML.load(File.read(schema_fixture_file))["person"]) }
  let(:schema){ MultiJson.load(schema_str, :symbolize_keys => true) }
  let(:virtus_module){ described_class.modularize(schema) }

  context "wrapper module" do
    subject { described_class.modularize(schema) }
    it { should be_kind_of Module }
    it { should be_include ::Virtus }
    it { should be_include JSON::Schematized::Models }
    it { should be_include described_class::Models }
    its(:name){ should =~ /\AJSON::Schematized::VirtusWrapper::JSD/ }
    its(:json_schema){ should == schema }
  end

  context "model classes" do
    subject { ::VPerson }
    it { should be_include ::Virtus }
    it { should be_include JSON::Schematized::Models }
    it { should be_include described_class::Models }
    it { should be_include described_class.modularize(schema) }
    its(:json_schema){ should == schema }

    context "attribute set names" do
      subject { ::VPerson.attribute_set.map(&:name).sort }
      it { should == [:address, :children, :email, :phones] }
    end

    context "submodel types" do
      it { should be_const_defined :Address }
      it { should be_const_defined :ChildrenCollection }
      it { should be_const_defined :Child }
      it { should be_const_defined :PhonesCollection }
    end
  end

  context "model instances" do
    subject { ::VPerson.new }
    its(:address){ should be_kind_of ::VPerson::Address }
    its(:phones){ should be_kind_of ::VPerson::PhonesCollection }
    its(:children){ should_not be_instance_of Array }
    its(:children){ should be_instance_of ::VPerson::ChildrenCollection }
    its(:children){ should be_kind_of described_class::Array }

    context "with mass assignment" do
      let(:phones){ ["555-1234"] }
      let(:address){ {:street_name => "Wall Street", :number => 1000} }
      let(:child){ {:name => "John", :age => 10} }
      let :attrs do
        {
          :email => "me@email.com", :phones => phones,
          :address => address, :children => [child]
        }
      end
      subject { ::VPerson.new attrs }
      its(:email){ should == "me@email.com" }
      its(:phones){ should == phones }
      its(:address){ should be_instance_of ::VPerson::Address }
      its(:"address.street_name"){ should == address[:street_name] }
      its(:"address.number"){ should == address[:number] }
      its(:"children.size"){ should be 1 }
      its(:"children.first"){ should be_instance_of ::VPerson::Child }
      its(:"children.first.name"){ should == child[:name] }
      its(:"children.first.age"){ should == child[:age] }
    end
  end

  context "collection classes" do
    subject { ::VPerson::ChildrenCollection }
    it { should be_include JSON::Schematized::Collections }
    it { should be_include described_class::Collections }
  end

  context "object" do
    let(:model) { Object.new.extend(virtus_module) }

    it "should have attributes to be defined" do
      model.should be_kind_of ::Virtus
      virtus_module.should be_const_defined :ComplexTypes
      model.should be_kind_of virtus_module::ComplexTypes

      model.should be_respond_to :email

      model.should be_respond_to :address
      virtus_module::ComplexTypes.should be_const_defined :Address
      model.address.should be_kind_of virtus_module::ComplexTypes::Address
    end
  end
end
