require "spec_helper"

class BPerson < Hash
  include JSON::Schematized
  json_schema :wrapper => :basic do
    YAML.load(File.read(File.expand_path("../../../../fixtures/person.yml", __FILE__)))["person"]
  end
end

describe ::JSON::Schematized::BasicWrapper do
  it_should_behave_like "a JSON::Schematized::Wrapper" do
    let(:model_class){ ::BPerson }
    context "model instances" do
      subject { model_class.new }
      its(:attributes){ should == {"phones" => [], "address" => {}} }
      its(:children){ should be_instance_of model_class::ChildrenCollection }
    end

    context "object" do
      let(:object_model){ Hash.new.extend(modularized_schema) }
      subject { object_model }
      it { should == {"phones" => [], "address" => {}} }
    end
  end
end
