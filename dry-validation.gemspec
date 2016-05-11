# coding: utf-8
require File.expand_path('../lib/dry/validation/version', __FILE__)

Gem::Specification.new do |spec|
  spec.name          = 'dry-validation'
  spec.version       = Dry::Validation::VERSION
  spec.authors       = ['Andy Holland', 'Piotr Solnica']
  spec.email         = ['andyholland1991@aol.com', 'piotr.solnica@gmail.com']
  spec.summary       = 'A simple validation library'
  spec.homepage      = 'https://github.com/dryrb/dry-validation'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'concurrent-ruby', '~> 1.0'
  spec.add_runtime_dependency 'dry-configurable', '~> 0.1', '>= 0.1.3'
  spec.add_runtime_dependency 'dry-container', '~> 0.2', '>= 0.2.8'
  spec.add_runtime_dependency 'dry-equalizer', '~> 0.2'
  spec.add_runtime_dependency 'dry-logic', '~> 0.2', '>= 0.2.3'
  spec.add_runtime_dependency 'dry-types', '~> 0.7', '>= 0.7.2'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
end
