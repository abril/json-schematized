require "spec_helper"

describe ::JSON::Schematized::VirtusWrapper do
  let(:schema_fixture_file){ File.expand_path("../../../../fixtures/person.yml", __FILE__) }
  let(:schema_str){ MultiJson.dump(YAML.load(File.read(schema_fixture_file))["person"]) }
  let(:schema){ MultiJson.load(schema_str, :symbolize_keys => true) }
  let(:virtus_module){ described_class.modularize(schema) }

  it "should create a Virtus module" do
    virtus_module.should be_kind_of Module
    virtus_module.name.should =~ /\AJSON::Schematized::VirtusWrapper::JSD/
    virtus_module.json_schema.should == schema
    virtus_module.should be_include ::Virtus
  end

  context "model" do
    let(:model_class){ VPerson }

    it "should return a virtus module" do
      VPerson.virtus_module.should be_kind_of Module
      VPerson.virtus_module.should be_include ::Virtus
    end

    it "should have attributes to be defined" do
      model_class.should be_include ::Virtus
      model_class.attribute_set.map(&:name).sort.should == [:address, :children, :email, :phones]
    end

    it "should define constants inside namespace" do
      model_class.should be_const_defined :Address
      model_class.const_get(:Address).should be VPerson::Address
      VPerson::Address.should be_include ::Virtus
      VPerson::Address.attribute_set.map(&:name).sort.should == [:number, :street_name]
      model_class.should be_const_defined :Child
      model_class.const_get(:Child).should be VPerson::Child
      VPerson::Child.attribute_set.map(&:name).sort.should == [:age, :name]
    end

    it "should use defined meta_type of attributes" do
      VPerson.new.tap do |person|
        person.address.should be_kind_of VPerson::Address
        person.phones.should be_kind_of VPerson::PhonesCollection
        person.children.should be_kind_of VPerson::ChildrenCollection
      end
    end

    it "should have collections to include Collections module" do
      VPerson::PhonesCollection.should be_include(described_class::Collections)
      VPerson::PhonesCollection.should be_include(JSON::Schematized::Collections)
    end
  end
end
