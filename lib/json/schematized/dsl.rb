# encoding: UTF-8

require "multi_json"

module JSON
  module Schematized
    module DSL
      def json_schema(json = nil, &block)
        if instance_variable_defined?(:"@json_schema")
          schema = @json_schema[:loader].call
          schema = MultiJson.dump(schema) unless schema.is_a?(String)
          MultiJson.load(schema, :symbolize_keys => true)
        else
          return if self === Base
          raise ArgumentError, "JSON or block expected" if block_given? ^ json.nil?
          block = Proc.new{ json } unless block_given?
          @json_schema = {:loader => block}
        end
      end
    end
  end
end
