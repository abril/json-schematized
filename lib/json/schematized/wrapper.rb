# encoding: UTF-8

module JSON
  module Schematized
    module Wrapper
      def modularize(json_schema, &block)
        json_schema = MultiJson.dump(json_schema) unless json_schema.is_a?(String)
        json_schema = MultiJson.load(json_schema, :symbolize_keys => true)
        module_name = "JSD#{json_schema.hash}".gsub(/\-/, "_").to_sym # JSON-Schema Definition
        if const_defined?(module_name)
          const_get(module_name)
        else
          const_set(module_name, Module.new).tap do |m|
            m.instance_variable_set(:@json_schema, json_schema)
            def m.json_schema; @json_schema; end
            m.module_eval(&block)
          end
        end
      end

      def meta_type(ref, field_name, meta, singularize = false)
        case meta[:type]
        when "string"
          String
        when "array"
          build_collection(ref, field_name, meta[:items])
        when "object"
          field_name = ::ActiveSupport::Inflector.singularize(field_name.to_s).to_sym if singularize
          build_model(ref, field_name, meta)
        else
          parse_json_schema_type meta[:type]
        end
      end

      def parse_json_schema_type(type)
        Object
      end

      def build_class_name(field_name)
        field_name.to_s.gsub(/(?:\A_*|_)([^_])/){ $1.upcase }
      end

      def build_collection(ref, field_name, meta)
        class_name = [build_class_name(field_name), "Collection"].join.to_sym
        meta_type = meta_type(ref, field_name, meta, true)
        if ref.const_defined?(class_name)
          ref.const_get(class_name)[meta_type]
        else
          ref.const_set(class_name, Class.new(Array)).class_eval do
            self
          end[meta_type]
        end
      end

      def build_model(ref, field_name, json_schema)
        class_name = build_class_name(field_name).to_sym
        _module = modularize(json_schema)
        (ref.const_defined?(class_name) ?
          ref.const_get(class_name) :
          ref.const_set(class_name, Class.new)
        ).tap do |klass|
          klass.send(:include, _module) unless klass.include?(_module)
        end
      end
    end
  end
end
