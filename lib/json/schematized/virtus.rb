# encoding: UTF-8

require "virtus"

module JSON
  module Schematized
    module Virtus
      def self.modularize(json_schema)
        json_schema = MultiJson.dump(json_schema) unless json_schema.is_a?(String)
        json_schema = MultiJson.load(json_schema, :symbolize_keys => true)
        module_name = "JSD#{json_schema.hash}".gsub(/\-/, "_").to_sym # JSON-Schema Definition
        if ::JSON::Schematized::Virtus.const_defined?(module_name)
          ::JSON::Schematized::Virtus.const_get(module_name)
        else
          ::JSON::Schematized::Virtus.const_set(module_name, Module.new).module_eval do
            include ::Virtus

            @@json_schema = json_schema
            def self.json_schema; @@json_schema; end
            # TODO: prepare attributes

            self
          end
        end
      end
    end
  end
end
