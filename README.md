# JSON::Schematized

Template builder based on JSON-Schema.

## Sample usage

Consider the following JSON-Schema (escaped as YAML, for better viewing):

```yaml
# person.yml
person:
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

Usage:

```ruby
require "json-schematized"

class Person < JSON::Schematized::Base
  json_schema do  # block called for each new instance
    YAML.load(File.read(File.expand_path("../person.yml", __FILE__)))["person"]
  end
end

person = Person.new name: "John", birth: {name: "John Smith"}
person.children        # => []
person.name            # => "John"
person.birth.name      # => "John Smith"
```
