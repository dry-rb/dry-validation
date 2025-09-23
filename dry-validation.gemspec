# frozen_string_literal: true

# This file is synced from hanakai-rb/repo-sync. To update it, edit repo-sync.yml.

lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "dry/validation/version"

Gem::Specification.new do |spec|
  spec.name          = "dry-validation"
  spec.authors       = ["Hanakai team"]
  spec.email         = ["info@hanakai.org"]
  spec.license       = "MIT"
  spec.version       = Dry::Validation::VERSION.dup

  spec.summary       = "Validation library"
  spec.description   = spec.summary
  spec.homepage      = "https://dry-rb.org/gems/dry-validation"
  spec.files         = Dir["CHANGELOG.md", "LICENSE", "README.md", "dry-validation.gemspec", "lib/**/*", "config/*.yml"]
  spec.bindir        = "bin"
  spec.executables   = []
  spec.require_paths = ["lib"]

  spec.metadata["allowed_push_host"] = "https://rubygems.org"
  spec.metadata["changelog_uri"]     = "https://github.com/dry-rb/dry-validation/blob/main/CHANGELOG.md"
  spec.metadata["source_code_uri"]   = "https://github.com/dry-rb/dry-validation"
  spec.metadata["bug_tracker_uri"]   = "https://github.com/dry-rb/dry-validation/issues"
  spec.metadata["funding_uri"]       = "https://github.com/sponsors/hanami"

  spec.required_ruby_version = ">= 3.1.0"

  spec.add_runtime_dependency "concurrent-ruby", "~> 1.0"
  spec.add_runtime_dependency "dry-core", "~> 1.1"
  spec.add_runtime_dependency "dry-initializer", "~> 3.2"
  spec.add_runtime_dependency "dry-schema", "~> 1.14"
  spec.add_runtime_dependency "zeitwerk", "~> 2.6"
  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
end

