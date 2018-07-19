lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "ya_enum/version"

Gem::Specification.new do |spec|
  spec.name          = "ya_enum"
  spec.version       = YaEnum::VERSION
  spec.authors       = ["David Pedersen"]
  spec.email         = ["david.pdrsn@gmail.com"]

  spec.summary       = %q{Enums in Ruby}
  spec.description   = %q{Enums in Ruby, that aren't just Java enums. We can do better than that}
  spec.homepage      = "http://github.com/tonsser/ya_enum"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"

  spec.add_dependency "takes_macro", ">= 1.0.0"
end
