require "spec_helper"

class SimplePerson < JSON::Schematized::Base
  json_schema do
    YAML.load(File.read(File.expand_path("../../../../fixtures/person.yml", __FILE__)))["person"]
  end
end

describe JSON::Schematized::Base do
  let(:described_class){ JSON::Schematized::BasicWrapper }
  it_should_behave_like "a JSON::Schematized::Wrapper" do
    let(:model_class){ SimplePerson }
  end
end
