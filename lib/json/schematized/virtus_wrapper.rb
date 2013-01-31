# encoding: UTF-8

require "virtus"

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
          include ::Virtus

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
          opts[:default] = klass.new if meta[:required] && kind.include?(::Virtus)
        else
          opts[:default] = kind.class.new
        end
        ref.attribute field_name, kind, opts
      end

      def self.collection_superclass
        Array
      end

      class Array < ::Array
      end

      module Attribute
        class Array < ::Virtus::Attribute::Array
          primitive VirtusWrapper::Array
          default primitive.new

          def new_collection
            (@primitive || self.class.primitive).new
          end

          def self.merge_options(type, options)
            merged_options = super
            klass = type.is_a?(Class) ? type : type.class
            merged_options.merge(:primitive => klass)
          end
        end
      end
    end
  end
end
