# encoding: UTF-8

class SamplePerson < JSON::Schematized::Base
  json_schema do
    YAML.load(File.read(File.expand_path("../sample_person.yml", __FILE__)))["sample_person"]
  end
end
