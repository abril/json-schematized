# encoding: UTF-8

module JSON
  module Schematized
    module Wrapper
      def self.extended(base)
        base.const_set(:Models, Module.new).send(:include, Schematized::Models)
        base.const_set(:Collections, Module.new).send(:include, Schematized::Collections)
      end

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
            m.send(:include, self::Models)
            m.module_eval do
              define_method :json_schema do
                m.json_schema
              end
            end
            m.module_eval(&block) if block_given?
          end
        end
      end

      def prepare_schema!(ref, json_schema, mode)
        modes = {
          :complex_types => 1,
          :simple_types => 2,
          :all_types => 3
        }
        mode = [modes[mode].to_i, 0].max
        accept_complex_types = (modes[:complex_types] & mode) > 0
        accept_simple_types = (modes[:simple_types] & mode) > 0
        json_schema[:properties].each_pair do |field_name, meta|
          kind = nil
          case meta[:type]
          when "array"
            next unless accept_complex_types
            collection = build_collection(ref, field_name, meta[:items])
            kind = collection
          when "object"
            next unless accept_complex_types
            model = build_model(ref, field_name, meta)
            kind = model
          else
            next unless accept_simple_types
            kind = meta_type(ref, field_name, meta)
          end
          add_attribute! ref, field_name, meta, kind
        end
      end

      def add_attribute!(ref, field_name, meta, kind)
      end

      def meta_type(ref, field_name, meta, singularize = false)
        case meta[:type]
        when "string"
          String
        when "array"
          build_collection(ref, field_name, meta[:items])
        when "object"
          build_model(ref, field_name, meta, singularize)
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

      def collection_superclass
        Array
      end

      def build_collection(ref, field_name, meta)
        class_name = [build_class_name(field_name), "Collection"].join.to_sym
        (ref.const_defined?(class_name) ?
          ref.const_get(class_name) :
          ref.const_set(class_name, Class.new(collection_superclass))
        ).tap do |klass|
          unless klass.include?(Schematized::Collections)
            klass.send(:include, self::Collections)
          end
        end[meta_type(ref, field_name, meta, true)]
      end

      def model_superclass
      end

      def build_model(ref, field_name, json_schema, singularize = false)
        name = field_name
        name = ::ActiveSupport::Inflector.singularize(field_name.to_s).to_sym if singularize
        class_name = build_class_name(name).to_sym
        (ref.const_defined?(class_name) ?
          ref.const_get(class_name) :
          ref.const_set(class_name, Class.new(*[model_superclass].compact))
        ).tap do |klass|
          unless klass.include?(Schematized::Models)
            klass.send(:include, self::Models)
            prepare_model(ref, field_name, klass, json_schema)
          end
        end
      end

      def prepare_model(ref, field_name, model_class, json_schema)
      end
    end
  end
end
