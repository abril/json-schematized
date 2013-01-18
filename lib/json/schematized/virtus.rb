# encoding: UTF-8

require "virtus"
require "active_support"

module JSON
  module Schematized
    module DSL
      def virtus_module
        Virtus.modularize(json_schema)
      end
    end

    module Virtus
      def self.modularize(json_schema)
        json_schema = MultiJson.dump(json_schema) unless json_schema.is_a?(String)
        json_schema = MultiJson.load(json_schema, :symbolize_keys => true)
        module_name = "JSD#{json_schema.hash}".gsub(/\-/, "_").to_sym # JSON-Schema Definition
        if ::JSON::Schematized::Virtus.const_defined?(module_name)
          ::JSON::Schematized::Virtus.const_get(module_name)
        else
          ::JSON::Schematized::Virtus.const_set(module_name, Module.new).module_eval do
            @json_schema = json_schema
            def self.json_schema; @json_schema; end

            Virtus.prepare_attributes!(self, json_schema)
            def self.included(base)
              Virtus.prepare_attributes!(base, json_schema, true)
            end

            self
          end
        end
      end

      def self.prepare_attributes!(ref, json_schema, build_subtypes = false)
        ref.send(:include, ::Virtus)
        json_schema[:properties].each_pair do |field_name, meta|
          case meta[:type]
          when "array"
            next unless build_subtypes
            opts = {}
            collection = build_collection(ref, field_name, meta)
            opts[:default] = collection.class.new if meta[:required]
            ref.attribute field_name, collection, opts
          when "object"
            next unless build_subtypes
            opts = {}
            model = build_model(ref, field_name, meta)
            opts[:default] = model.new if meta[:required]
            ref.attribute field_name, model, opts
          else
            ref.attribute field_name, meta_type(ref, field_name, meta)
          end
        end
      end

      def self.build_class_name(field_name)
        field_name.to_s.gsub(/(?:\A_*|_)([^_])/){ $1.upcase }
      end

      def self.meta_type(ref, field_name, meta, singularize = false)
        case meta[:type]
        when "string"
          String
        when "array"
          build_collection(ref, field_name, meta[:items])
        when "object"
          field_name = ::ActiveSupport::Inflector.singularize(field_name.to_s).to_sym if singularize
          build_model(ref, field_name, meta)
        else
          Object
        end
      end

      def self.build_collection(ref, field_name, meta)
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

      def self.build_model(ref, field_name, json_schema)
        class_name = build_class_name(field_name).to_sym
        _module = Virtus.modularize(json_schema)
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
