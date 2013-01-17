Gem::Specification.new do |s|
  s.name          = "json-schematized"
  s.version       = "0.1.0"
  s.platform      = Gem::Platform::RUBY
  s.summary       = "Template builder based on JSON-Schema"
  s.require_paths = ["lib"]
  s.files         = Dir["lib/**/*.rb", "README.md", "Gemfile*"]

  s.description   = ""
  s.authors       = ["Marcelo Manzan"]
  s.email         = "manzan@gmail.com"
  s.homepage      = "http://github.com/abril"

  s.add_dependency "multi_json", "~> 1.0"
  s.add_dependency "virtus"

  s.add_development_dependency "json", "~> 1.4"
  s.add_development_dependency "rspec", ">= 2.6"
end
