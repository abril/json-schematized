# encoding: UTF-8
module JSON
  module Schematized
    class Base
      extend DSL
      include SchematizedObject

      attr_reader :__json__

      def to_json
        MultiJson.dump __json__
      end

      def initialize(attrs = nil)
        @__json__ = {}
        @__schema__ = Builder.new(self.class.json_schema)
        __schema__.copy_to(__json__, attrs)
      end
    end
  end
end
