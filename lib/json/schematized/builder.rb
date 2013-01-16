# encoding: UTF-8
module JSON
  module Schematized
    class Builder
      attr_reader :schema

      def initialize(schema, ensure_structure = true)
        @schema = schema
        @ensure_structure = ensure_structure
      end

      def member?(key)
        schema[:properties][key.to_sym]
      end

      def copy_to(json, attrs)
        if json.is_a?(Array)
          return unless attrs.is_a?(Array)
          attrs.each{ |value| assign!(json, nil, schema, value) }
        else
          return unless attrs.is_a?(Hash)
          attrs.each_pair do |key, value|
            meta = member?(key)
            assign!(json, key, meta, value) if meta
          end
        end
        ensure_structure!(json, schema) if ensure_structure?
        json
      end

      def ensure_structure?
        @ensure_structure
      end

      def ensure_structure!(json, schema)
        case json
        when Array
          meta = schema[:items]
          case meta && meta[:type]
          when "object", "array"
            json.each do |value|
              ensure_structure!(value, meta)
            end
          end
        when Hash
          meta = schema[:properties]
          meta.each_pair do |key, schema|
            case value = json[key.to_s]
            when Hash
              ensure_structure!(value, schema) if schema[:type] == "object"
            when Array
              ensure_structure!(value, schema) if schema[:type] == "array"
            when nil
              if schema[:required]
                case schema[:type]
                when "object"
                  ensure_structure!(json[key.to_s] = {}, schema)
                when "array"
                  ensure_structure!(json[key.to_s] = [], schema)
                end
              end
            end
          end
        end
      end

      def assign!(json, key, meta, value)
        case meta[:type]
        when "object"
          value = self.class.new(meta, false).copy_to({}, value)
        when "array"
          value = self.class.new(meta[:items], false).copy_to([], value)
        end
        if json.is_a?(Array)
          json << value
        else
          json[key.to_s] = value
        end
      end
    end
  end
end
