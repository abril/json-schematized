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
        end
      end

      def self.build_collection(ref, field_name, meta)
        super[meta_type(ref, field_name, meta, true)]
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
