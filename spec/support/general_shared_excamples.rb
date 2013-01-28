# encoding: UTF-8

shared_examples "a JSON::Schematized::Wrapper" do
  let(:schema_fixture_file){ File.expand_path("../../fixtures/person.yml", __FILE__) }
  let(:schema_str){ MultiJson.dump(YAML.load(File.read(schema_fixture_file))["person"]) }

  let(:schema){ MultiJson.load(schema_str, :symbolize_keys => true) }
  let(:modularized_schema){ described_class.modularize(schema) }

  context "wrapper module" do
    subject { described_class.modularize(schema) }
    it { should be_kind_of Module }
    it { should be_include JSON::Schematized::Models }
    it { should be_include described_class::Models }
    its(:name){ should =~ /\A#{described_class}::JSD/ }
    its(:json_schema){ should == schema }
  end

  context "model classes" do
    subject { model_class }
    it { should be_include described_class }
    it { should be_include JSON::Schematized::Models }
    it { should be_include described_class::Models }
    its(:json_schema){ should == schema }

    context "attribute set names" do
      subject { model_class.attribute_set.map(&:name) }
      it { should be_include :address }
      it { should be_include :children }
      it { should be_include :email }
      it { should be_include :phones }
    end

    context "submodel types" do
      it { should be_const_defined :Address }
      it { should be_const_defined :ChildrenCollection }
      it { should be_const_defined :Child }
      it { should be_const_defined :PhonesCollection }
    end

    context "submodel Address attribute set names" do
      subject { model_class::Address.attribute_set.map(&:name) }
      it { should be_include :street_name }
      it { should be_include :number }
    end

    context "submodel Child attribute set names" do
      subject { model_class::Child.attribute_set.map(&:name) }
      it { should be_include :name }
      it { should be_include :age }
    end
  end

  context "model instances" do
    subject { model_class.new }
    its(:address){ should be_kind_of model_class::Address }
    its(:phones){ should be_kind_of model_class::PhonesCollection }
    its(:children){ should_not be_instance_of ::Array }
    its(:children){ should be_instance_of model_class::ChildrenCollection }
    its(:children){ should be_kind_of ::Array }

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
      subject { model_class.new attrs }
      its(:email){ should == "me@email.com" }
      its(:phones){ should == phones }
      its(:address){ should be_instance_of model_class::Address }
      its(:"address.street_name"){ should == address[:street_name] }
      its(:"address.number"){ should == address[:number] }
      its(:"children.size"){ should be 1 }
      its(:"children.first"){ should be_instance_of model_class::Child }
      its(:"children.first.name"){ should == child[:name] }
      its(:"children.first.age"){ should == child[:age] }
    end
  end

  context "collection classes" do
    subject { model_class::ChildrenCollection }
    it { should be_include JSON::Schematized::Collections }
    it { should be_include described_class::Collections }
  end

  context "object" do
    let(:object_model){ Hash.new.extend(modularized_schema) }
    subject { object_model }
    before { object_model.children = [{}] }

    its(:class){ should_not be_const_defined :Address }
    it { should be_kind_of modularized_schema::ComplexTypes }
    it { should be_respond_to :email }
    it { should be_respond_to :address }
    its(:address){ should be_kind_of modularized_schema::ComplexTypes::Address }
    its(:phones){ should be_kind_of modularized_schema::ComplexTypes::PhonesCollection }
    its(:children){ should_not be_instance_of ::Array }
    its(:children){ should be_instance_of modularized_schema::ComplexTypes::ChildrenCollection }
    its(:children){ should be_kind_of ::Array }
    its(:"children.size"){ should be 1 }
    its(:"children.first"){ should be_instance_of modularized_schema::ComplexTypes::Child }
  end
end
