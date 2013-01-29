# JSON::Schematized

[![Build Status](https://travis-ci.org/abril/json-schematized.png?branch=master)](https://travis-ci.org/abril/json-schematized)

Object builder based on JSON-Schema.

## Sample usage

Consider the following JSON-Schema (escaped as YAML, for better viewing):

```yaml
# person.yml
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
```

### Basic Wrapper Usage

```ruby
require "json-schematized"

class Person < JSON::Schematized::Base
  json_schema do  # block called for each new instance
    YAML.load(File.read(File.expand_path("../person.yml", __FILE__)))["person"]
  end
end

person = Person.new name: "John", children: [{name: "William"}]
person.name                     # => "John"
person.children                 # => [{"name" => "William"}]
person.children.class           # => Person::ChildrenCollection
person.children.first.class     # => Person::Child
person.children.first.name      # => "William"
```

Another way to use Basic Wrapper is as follows:

```ruby
class Person < Hash
  include JSON::Schematized
  json_schema wrapper: :basic do  # block called for each new instance
    YAML.load(File.read(File.expand_path("../person.yml", __FILE__)))["person"]
  end
end
```

### Virtus Wrapper Usage

```ruby
require "json-schematized"

class Person
  include JSON::Schematized
  json_schema wrapper: :virtus do  # block called only once
    YAML.load(File.read(File.expand_path("../person.yml", __FILE__)))["person"]
  end
end

person = Person.new name: "John", children: [{name: "William"}]
person.name                     # => "John"
person.children                 # => [#<Person::Child:0x007fc990906fd0 @name="William">]
person.children.class           # => Person::ChildrenCollection
person.children.first.class     # => Person::Child
person.children.first.name      # => "William"
```

### Object with Basic Wrapper usage

```ruby
person = Hash.new
json_schema = YAML.load(File.read(File.expand_path("../person.yml", __FILE__)))["person"]
person.extend JSON::Schematized::BasicWrapper.modularize(json_schema)

person.children << {}
# ...
```
