# encoding: UTF-8

lib_path = File.expand_path("../lib", __FILE__)
$:.unshift(lib_path) unless $:.include?(lib_path) || ! File.exists?(lib_path)

require "json/schematized/version"

Gem::Specification.new do |s|
  s.name          = "json-schematized"
  s.version       = JSON::Schematized::VERSION
  s.platform      = Gem::Platform::RUBY
  s.summary       = "Object builder based on JSON-Schema"
  s.require_paths = ["lib"]
  s.files         = %w[GEM_VERSION] + `git ls-files -- Gemfile README.md lib/ script/ *.gemspec`.split("\n")
  s.test_files    = `git ls-files -- .rspec Gemfile spec/`.split("\n")

  s.description   = ""
  s.authors       = ["Marcelo Manzan"]
  s.email         = "manzan@gmail.com"
  s.homepage      = "http://github.com/abril"

  s.add_runtime_dependency "multi_json", "~> 1.0"
  s.add_runtime_dependency "activesupport"
  s.add_runtime_dependency "virtus"

  s.add_development_dependency "json", "~> 1.4"
  s.add_development_dependency "rspec", ">= 2.6"
  s.add_development_dependency "step-up", ">= 0.8.2"
end
