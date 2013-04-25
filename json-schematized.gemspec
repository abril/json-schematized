Gem::Specification.new do |s|
  s.name          = "json-schematized"
  s.version       = "0.2.2"
  s.platform      = Gem::Platform::RUBY
  s.summary       = "Object builder based on JSON-Schema"
  s.require_paths = ["lib"]
  s.files         = `git ls-files -- Gemfile README.md lib/ script/ *.gemspec`.split("\n")
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
end
