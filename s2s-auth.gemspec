# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 's2s/auth/version'

Gem::Specification.new do |spec|
  spec.name          = "s2s-auth"
  spec.version       = S2S::Auth::VERSION
  spec.authors       = ["Matt Aimonetti"]
  spec.email         = ["mattaimonetti@gmail.com"]
  spec.summary       = %q{S2S authentication lib based on ActiveSupport's crypto.}
  spec.description   = %q{Generates/parses encrypted and signed tokens.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"

  spec.add_dependency "activesupport", ">= 3.0"
end
