# encoding: UTF-8

require "virtus"

if ::Virtus.respond_to? :module
  require File.expand_path '../virtus_1_x_x_wrapper.rb', __FILE__
else
  require File.expand_path '../virtus_0_5_x_wrapper.rb', __FILE__
end
