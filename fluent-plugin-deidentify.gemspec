lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name    = "fluent-plugin-deidentify"
  spec.version = "0.1.0"
  spec.authors = ["Stefano Charissis"]
  spec.email   = ["scharissis@woolworths.com.au"]

  spec.summary       = "Deidentification methods to redact or mask private data from records."
  spec.homepage      = "https://github.com/scharissis/fluent-plugin-deidentify"
  spec.license       = "MIT"

  test_files, files  = `git ls-files -z`.split("\x0").partition do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.files         = files
  spec.executables   = files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = test_files
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 2.2.9"
  spec.add_development_dependency "rake", "~> 12.0"
  spec.add_development_dependency "test-unit", "~> 3.0"
  spec.add_runtime_dependency "fluentd", ">= 1", "< 2"
end
