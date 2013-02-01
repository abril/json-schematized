# encoding: UTF-8

require "virtus"

module JSON
  module Schematized
    module BasicWrapper
      extend Wrapper

      def self.included(base)
        raise TypeError, "#{base.inspect} should inherits #{model_superclass}" unless base < model_superclass
        base.send(:include, Models)
        base.extend ClassMethods
        prepare_schema!(base, base.json_schema, :complex_types)
      end

      module ClassMethods
        def attribute_set
          json_schema_module.attribute_set
        end

        def json_schema_module
          BasicWrapper.modularize(json_schema)
        end
      end

      def initialize(attrs = nil)
        self.json_schema = self.class.json_schema
        self.attributes = attrs
      end

      def self.modularize(json_schema)
        super(json_schema) do
          include BasicWrapper::SchematizedHash

          def self.attribute_set
            unless defined?(@attribute_set)
              set = []
              json_schema[:properties].each_pair do |field_name, meta|
                set << Virtus::Attribute.build(field_name, BasicWrapper.meta_type(self, field_name, meta))
              end
              @attribute_set = Virtus::AttributeSet.new(nil, set)
            end
            @attribute_set
          end

          def self.extend_object(base)
            super
            return if base.class.include? BasicWrapper::Models
            class_name = :ComplexTypes
            (const_defined?(class_name) ?
              const_get(class_name) :
              const_set(class_name, Module.new)
            ).tap do |klass|
              unless klass.include?(self)
                klass.send(:include, self)
                klass.instance_variable_set(:@attribute_set, self.attribute_set)
                klass.module_eval do
                  def self.attribute_set
                    @attribute_set
                  end
                  define_method :subclasses_namespace do
                    klass
                  end
                end
              end
              base.extend klass
            end
          end
        end
      end

      def self.prepare_model(ref, field_name, model_class, json_schema)
        model_class.extend BasicWrapper::ClassMethods
        parent_namespace = {:ref => ref, :field => field_name.to_sym}
        model_class.instance_variable_set(:@parent_namespace, parent_namespace)
        def model_class.json_schema
          json_schema = @parent_namespace[:ref].json_schema
          meta = json_schema[:properties][@parent_namespace[:field]] || {}
          meta = meta[:items] if meta[:type] == "array"
          meta
        end
        prepare_schema!(model_class, json_schema, :complex_types)
      end

      def self.model_superclass
        ::Hash
      end

      module Models
        def json_schema=(json_schema)
          extend BasicWrapper.modularize(json_schema)
        end
      end

      module Collections
        def coerce_members_to(member_type, json_schema)
          extend BasicWrapper::SchematizedArray
          self.members_type = member_type
          self.members_module = BasicWrapper.modularize(json_schema)
        end
      end

      module SchematizedArray
        attr_accessor :members_type
        attr_accessor :members_module

        def coerce_members_to(*args); end

        def <<(value)
          if members_module.json_schema[:type] == "object"
            new_value = members_type.new
            new_value.extend members_module
            new_value.attributes = value if value.is_a?(Hash)
            super(new_value)
          else
            super
          end
        end

        def mass_assign!(array)
          array.each do |value|
            self << value
          end
        end
      end

      module SchematizedHash
        def method_missing(name, *args)
          key = name.to_s
          if key =~ /=\z/
            key = $`.to_sym
            if json_schema[:properties][key]
              self[key] = args.first
            else
              super
            end
          else
            read_attribute key
          end
        end

        def attributes
          self
        end

        def json_schema=(*args); end

        def respond_to?(method_name)
          json_schema[:properties].has_key?(method_name.to_sym) || super
        end

        def subclasses_namespace
          self.class
        end

        def []=(key, value)
          if meta = json_schema[:properties][key.to_sym]
            case meta[:type]
            when "array"
              collection = BasicWrapper.build_collection(subclasses_namespace, key, meta[:items])
              new_value = collection.class.new
              new_value.coerce_members_to(collection.first, meta[:items])
              new_value.mass_assign!(value) if value.is_a?(Array)
              value = new_value
            when "object"
              model_class = BasicWrapper.build_model(subclasses_namespace, key, meta)
              new_value = model_class.new
              new_value.json_schema = meta
              new_value.attributes = value if value.is_a?(Hash)
              value = new_value
            else
              value = subclasses_namespace.attribute_set[key.to_sym].coerce(value)
            end
          end
          super(key.to_s, value)
        end

        def attributes=(hash)
          return unless hash.is_a?(Hash)
          hash.each_pair do |key, value|
            self[key] = value
          end
        ensure
          SchematizedHash.ensure_structure!(self, json_schema)
        end

        def read_attribute(name)
          name = name.to_s
          value = self[name]
          if !has_key?(name) && (meta = json_schema[:properties][name.to_sym])
            case meta[:type]
            when "array"
              self[name] = []
              value = self[name]
            when "object"
              self[name] = {}
              value = self[name]
            end
          end
          value
        end

        def self.ensure_structure!(json, schema)
          meta = schema[:properties]
          meta.each_pair do |key, schema|
            if !json.has_key?(key.to_s) && schema[:required]
              json[key.to_s] = case schema[:type]
                when "object" then {}
                when "array" then []
                else nil
              end
            end
          end
        end
      end
    end
  end
end
