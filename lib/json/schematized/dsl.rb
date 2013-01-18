# encoding: UTF-8

require "multi_json"

module JSON
  module Schematized
    module DSL
      def json_schema(*args, &block)
        if instance_variable_defined?(:"@json_schema")
          schema = @json_schema[:loader].call
          schema = MultiJson.dump(schema) unless schema.is_a?(String)
          MultiJson.load(schema, :symbolize_keys => true)
        else
          return if self === Base
          opts = args.last.is_a?(Hash) ? args.pop : {}
          json = args.first
          raise ArgumentError, "JSON or block expected" if block_given? ^ json.nil?
          block = Proc.new{ json } unless block_given?
          @json_schema = {:loader => block}
          send(:include, Virtus.modularize(@json_schema[:loader].call)) if opts[:virtus].nil? || opts[:virtus]
          self
        end
      end
    end
  end
end
