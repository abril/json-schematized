# encoding: UTF-8

require "multi_json"

module JSON
  module Schematized
    module DSL
      def json_schema(*args, &block)
        if instance_variable_defined?(:"@json_schema_loader")
          schema = @json_schema_loader.call
          schema = MultiJson.dump(schema) unless schema.is_a?(String)
          MultiJson.load(schema, :symbolize_keys => true)
        else
          opts = args.last.is_a?(Hash) ? args.pop : {}
          json = args.first
          raise ArgumentError, "JSON or block expected" if block_given? ^ json.nil?
          block = Proc.new{ json } unless block_given?
          @json_schema_loader = block
          wrapper = "#{opts.fetch(:wrapper, :basic)}_wrapper".gsub(/(?:\A_*|_)([^_])/){ $1.upcase }.to_sym
          include Schematized.const_get(wrapper) if Schematized.const_defined?(wrapper)
          self
        end
      end
    end
  end
end
