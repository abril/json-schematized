# encoding: UTF-8
$:.unshift(File.dirname(__FILE__)) unless $:.include?(File.dirname(__FILE__))

require "rubygems"
require "active_support"

module JSON
  module Schematized
    autoload :Base, "json/schematized/base"
    autoload :Builder, "json/schematized/builder"
    autoload :DSL, "json/schematized/dsl"
    autoload :Wrapper, "json/schematized/wrapper"
    autoload :VirtusWrapper, "json/schematized/virtus_wrapper"

    def self.included(base)
      base.extend DSL
    end

    module Models; end
    module Collections; end
  end
end

require "json/schematized_objects"
