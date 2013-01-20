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
          wrapper = "#{opts.fetch(:wrapper, :none)}_wrapper".gsub(/(?:\A_*|_)([^_])/){ $1.upcase }.to_sym
          wrapper =  Schematized.const_defined?(wrapper) ? Schematized.const_get(wrapper) : nil
          send(:include, wrapper.modularize(@json_schema[:loader].call)) if wrapper
          self
        end
      end
    end
  end
end
