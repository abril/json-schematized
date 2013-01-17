# encoding: UTF-8
$:.unshift(File.dirname(__FILE__)) unless $:.include?(File.dirname(__FILE__))

require "rubygems"

module JSON
  module Schematized
    autoload :Base, "json/schematized/base"
    autoload :Builder, "json/schematized/builder"
    autoload :DSL, "json/schematized/dsl"
    autoload :Virtus, "json/schematized/virtus"
  end
end

require "json/schematized_objects"
