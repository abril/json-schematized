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

          VirtusWrapper.prepare_attributes!(self, self.json_schema)
          def self.included(base)
            super
            VirtusWrapper.prepare_attributes!(base, json_schema, true)
          end
        end
      end

      def self.prepare_attributes!(ref, json_schema, included = false)
        json_schema[:properties].each_pair do |field_name, meta|
          case meta[:type]
          when "array"
            next unless included
            opts = {}
            collection = build_collection(ref, field_name, meta)
            opts[:default] = proc { collection.class.new } if meta[:required]
            ref.attribute field_name, collection, opts
          when "object"
            next unless included
            opts = {}
            model = build_model(ref, field_name, meta)
            opts[:default] = proc { model.new } if meta[:required]
            ref.attribute field_name, model, opts
          else
            next if included
            ref.attribute field_name, meta_type(ref, field_name, meta)
          end
        end
      end
    end
  end
end
