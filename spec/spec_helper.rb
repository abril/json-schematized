# encoding: UTF-8
gemlib = File.expand_path("../../lib", __FILE__)
$:.unshift(gemlib) unless $:.include?(gemlib)

require "json-schematized"
require "json"
require "yaml"


# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[File.expand_path("../support/**/*.rb", __FILE__)].each{ |f| require f }
