# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'reverb/api/version'

Gem::Specification.new do |spec|
  spec.name          = "reverb-api"
  spec.version       = Reverb::Api::VERSION
  spec.authors       = ["pdebelak", "skwp"]
  spec.email         = ["peterd@reverb.com", "yan@reverb.com"]

  spec.summary       = %q{Reverb API Client}
  spec.description   = %q{Access the Reverb API}
  spec.homepage      = "https://github.com/reverbdev/reverb-api.rb"
  spec.license       = "Apache License Version 2.0"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "httparty"
  spec.add_dependency "hashr"

  spec.add_development_dependency "bundler", "~> 1.8"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "vcr"
  spec.add_development_dependency "webmock"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "pry-nav"
end
