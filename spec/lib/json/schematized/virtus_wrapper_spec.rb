require "spec_helper"

class VPerson
  include JSON::Schematized
  json_schema :wrapper => :virtus do
    YAML.load(File.read(File.expand_path("../../../../fixtures/person.yml", __FILE__)))["person"]
  end
end

describe ::JSON::Schematized::VirtusWrapper do
  it_should_behave_like "a JSON::Schematized::Wrapper" do
    let(:model_class){ ::VPerson }
    let(:object_model_module) { modularized_schema::ComplexTypes }

    context "model classes" do
      subject { model_class }
      it { should be_include described_class.modularize(schema) }
    end
  end
end
