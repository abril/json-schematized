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
              unless klass.include?(::Virtus)
                klass.send(:include, ::Virtus)
                VirtusWrapper.prepare_schema!(klass, json_schema, :complex_types)
              end
              base.extend klass
            end
          end
        end
      end

      def self.add_attribute!(ref, field_name, meta, kind)
        opts = {}
        if meta[:required]
          klass = kind.is_a?(Class) ? kind : kind.class
          opts[:default] = proc { klass.new }
        end
        ref.attribute field_name, kind, opts
      end
    end
  end
end
