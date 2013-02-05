# encoding: UTF-8
$:.unshift(File.dirname(__FILE__)) unless $:.include?(File.dirname(__FILE__))

require "rubygems"
require "active_support"

module JSON
  module Schematized
    autoload :Base, "json/schematized/base"
    autoload :DSL, "json/schematized/dsl"
    autoload :Wrapper, "json/schematized/wrapper"
    autoload :BasicWrapper, "json/schematized/basic_wrapper"
    autoload :VirtusWrapper, "json/schematized/virtus_wrapper"
    autoload :VERSION, "json/schematized/version"
    autoload :Version, "json/schematized/version"

    def self.included(base)
      base.extend DSL
    end

    module Models; end
    module Collections; end
  end
end
