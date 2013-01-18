# encoding: UTF-8
class VPerson
  include JSON::Schematized
  json_schema do
    YAML.load(File.read(File.expand_path("../../../fixtures/person.yml", __FILE__)))["person"]
  end
end
