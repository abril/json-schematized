# encoding: UTF-8

module JSON
  module Schematized
    module DSL
      def virtus_module
        VirtusWrapper.modularize(json_schema)
      end
    end

    module VirtusWrapper
      extend Wrapper

      def self.included(base)
        base.send(:include, modularize(base.json_schema))
        base.extend ClassMethods
      end

      module ClassMethods
        def json_schema_module
          VirtusWrapper.modularize(json_schema)
        end
      end

      def self.modularize(json_schema)
        super(json_schema) do
          include ::Virtus.module

          VirtusWrapper.prepare_schema!(self, self.json_schema, :simple_types)
          def self.included(base)
            super
            VirtusWrapper.prepare_schema!(base, json_schema, :complex_types)
          end

          def self.extend_object(base)
            class_name = :ComplexTypes
            (const_defined?(class_name) ?
              const_get(class_name) :
              const_set(class_name, Module.new)
            ).tap do |klass|
              klass.send(:include, self) unless klass.include?(self)
              base.extend klass
            end
          end
        end
      end

      def self.prepare_model(ref, field_name, model_class, json_schema)
        model_class.send(:include, modularize(json_schema))
      end

      def self.add_attribute!(ref, field_name, meta, kind)
        opts = {}
        klass =  (kind.is_a?(Class) ? kind : kind.class)
        if kind.is_a?(Class)
          opts[:default] = proc { klass.new } if meta[:required] && kind.include?(VirtusWrapper::Models)
        else
          opts[:default] = proc { kind.class.new }
        end
        ref.attribute field_name, kind, opts
      end

      def self.collection_superclass
        Array
      end

      class Array < ::Array
      end

      module Attribute
        class Array < ::Virtus::Attribute::Collection
          primitive VirtusWrapper::Array
          default Proc.new { |_, attribute| attribute.primitive.new }
        end
      end
    end
  end
end
