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

  # required helpers to shared examples
  let(:schema){ MultiJson.load(schema_str, :symbolize_keys => true) }
  let(:modularized_schema){ described_class.modularize(schema) }
  let(:model_class){ ::VPerson }

  it_should_behave_like "a JSON::Schematized::Wrapper"
end
