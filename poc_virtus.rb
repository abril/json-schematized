require "yaml"

require "rubygems"
require "virtus"

module JsonSchema

  # Load JsonSchema from YAML
  #
  # yaml_string - YAML in string
  #
  # Returns JsonSchema::Reader instance, naming with the first key from Json.
  def self.load_yaml(yaml_string)
    schema = YAML.load(yaml_string)
    name = schema.keys.first
    Reader.new(name, schema)
  end

  # Reader responsible for parsing *root_object* and *inner_objects* from
  # JSON Schema into Ruby code.
  #
  # Examples
  #
  #   reader = Reader.new("person", schema_hash)
  #   reader.to_ruby
  #
  class Reader

    attr_reader :schema, :name

    # Initialize Reader
    #
    # name - id of json schema
    # schema - schema hash
    def initialize(name, schema)
      @name = name
      @schema = schema
    end

    # Root SchemaObject from schema
    def root_object
      @root_object ||= SchemaObject.parse(name, schema[name])
    end

    # Inner SchemaObjects from root_object
    def inner_objects
      inner_objects = []
      root_object.properties.each do |attr|
        if attr.type == "object"
          scoped_schema = schema[name]["properties"][attr.name]
          inner_objects << SchemaObject.parse(attr.name, scoped_schema)
        elsif attr.type == "array"
          scoped_schema = schema[name]["properties"][attr.name]["items"]
          inner_objects << SchemaObject.parse(attr.name, scoped_schema)
        end
      end
      inner_objects
    end

    # See JsonSchema::VirtusStyle.to_ruby
    def to_ruby
      VirtusStyle.to_ruby(self)
    end

  end

  class VirtusStyle

    # Output Ruby code
    #
    # schema_reader - JsonSchema::Reader instance.
    #
    # Examples
    #
    #   class Birth
    #      include Virtus
    #      attribute :name, String
    #    end
    #    class Children
    #      include Virtus
    #      attribute :name, String
    #    end
    #
    #   include Virtus
    #   attribute :name, String
    #   attribute :birth, Birth
    #   attribute :children, Array[Children]
    #
    # Returns String with Ruby code setting Virtus's attributes.
    def self.to_ruby(schema_reader)
      self.new(schema_reader).to_ruby
    end

    def initialize(schema_reader)
      @reader = schema_reader
    end

    def to_ruby
      out = @reader.inner_objects.inject("") do |out, schema_object|
        out << %{
          class #{schema_object.name.capitalize}
            include Virtus
            #{properties_to_ruby(schema_object.properties)}
          end
        }
      end
      out << %{
      include Virtus
        #{properties_to_ruby(@reader.root_object.properties)}
      }
    end

    private

    # Internals: Helper to output properties like Virtus's attributes
    def properties_to_ruby(properties)
      properties.inject("") do |out, property|
        out << %{attribute :#{property.name}, #{attribute_type(property)}\n#{' '*6}}
      end
    end

    # Internals: Helper to output property type like Virtus's attributes type
    #
    # property - JsonSchema::SchemaProperty instance
    #
    # Returns String with Virtus's attribute style
    def attribute_type(property)
      if property.type == "object"
        property.name.capitalize
      elsif property.type == "array"
        "Array[#{property.name.capitalize}]"
      else
        property.type.capitalize
      end
    end

  end

  class SchemaProperty
    attr_reader :name, :type

    def initialize(name, type)
      @name = name
      @type = type
    end

    def self.parse(properties)
      parsed_attributes = []
      properties.each_pair do |attr, props|
        parsed_attributes << self.new(attr, props["type"])
      end
      parsed_attributes
    end

  end

  class SchemaObject
    attr_reader :name, :type, :properties

    def initialize(name, type, properties)
      @name = name
      @type = type
      @properties = properties
    end

    def self.parse(name, schema)
      type = schema["type"]
      properties = schema["properties"]
      properties = SchemaProperty.parse(properties)
      self.new(name, type, properties)
    end

  end

end

class Object

  # Public: Creates a module "on the fly" with objects and attributes from
  # JSON Schema.
  def JsonSchemaFrom(yaml_string)
    reader = JsonSchema.load_yaml(yaml_string)
    # SUPER DEBUG
    #puts %{Module.new.instance_eval("
    #  #{reader.to_ruby}
    #")}
    # TODO: memoize this result somehow
    Module.new.instance_eval(reader.to_ruby)
  end

end

class Person
  include JsonSchemaFrom(DATA.read)
end

person = Person.new(name: "John", birth: {name: "John Smith"})
#person.children = [{:name => "c1"}, {:name => "c2"}]
puts person.children.inspect # => []
puts person.name             # => "John"
puts person.birth.name       # => "John Smith"

# usage:
# $ ruby poc_virtus.rb

__END__
person:
  type: object
  properties:
    name:
      type: string
    birth:
      type: object
      properties:
        name:
          type: string
    children:
      type: array
      required: true
      items:
        type: object
        properties:
          name:
            type: string
