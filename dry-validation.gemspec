# frozen_string_literal: true

require File.expand_path('lib/dry/validation/version', __dir__)

Gem::Specification.new do |spec|
  spec.name          = 'dry-validation'
  spec.version       = Dry::Validation::VERSION
  spec.authors       = ['Piotr Solnica']
  spec.email         = ['piotr.solnica@gmail.com']
  spec.summary       = 'Validation library'
  spec.homepage      = 'https://dry-rb.org/gems/dry-validation'
  spec.license       = 'MIT'

  spec.files         = Dir['CHANGELOG.md', 'LICENSE', 'README.md', 'lib/**/*', 'config/*.yml']
  spec.executables   = []
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']
  spec.required_ruby_version = '>= 2.3'

  spec.add_runtime_dependency 'concurrent-ruby', '~> 1.0'
  spec.add_runtime_dependency 'dry-core', '~> 0.4'
  spec.add_runtime_dependency 'dry-equalizer', '~> 0.2'
  spec.add_runtime_dependency 'dry-container', '~> 0.7', '>= 0.7.1'
  spec.add_runtime_dependency 'dry-initializer', '~> 3.0'
  spec.add_runtime_dependency 'dry-schema', '~> 1.0', '>= 1.4.3'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
end
