# coding: utf-8
require File.expand_path('../lib/dry/validation/version', __FILE__)

Gem::Specification.new do |spec|
  spec.name          = 'dry-validation'
  spec.version       = Dry::Validation::VERSION
  spec.authors       = ['Andy Holland']
  spec.email         = ['andyholland1991@aol.com']
  spec.summary       = 'A simple validation library'
  spec.homepage      = 'https://github.com/dryrb/dry-validation'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'dry-configurable'
  spec.add_runtime_dependency 'dry-container'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
end
