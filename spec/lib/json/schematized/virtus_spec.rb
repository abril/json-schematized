require "spec_helper"

describe ::JSON::Schematized::Virtus do
  let(:schema_fixture_file){ File.expand_path("../../../../support/sample_person.yml", __FILE__) }
  let(:schema_str){ MultiJson.dump(YAML.load(File.read(schema_fixture_file))["sample_person"]) }
  let(:schema){ MultiJson.load(schema_str, :symbolize_keys => true) }
  let(:virtus_module){ described_class.modularize(schema) }

  it "should create a Virtus module" do
      virtus_module.should be_kind_of(Module)
      virtus_module.name.should =~ /\AJSON::Schematized::Virtus::JSD/
      virtus_module.json_schema.should == schema
      virtus_module.should be_include(::Virtus)
  end
end
