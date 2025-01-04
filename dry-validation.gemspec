# frozen_string_literal: true

# this file is synced from dry-rb/template-gem project

lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "dry/validation/version"

Gem::Specification.new do |spec|
  spec.name          = "dry-validation"
  spec.authors       = ["Piotr Solnica"]
  spec.email         = ["piotr.solnica@gmail.com"]
  spec.license       = "MIT"
  spec.version       = Dry::Validation::VERSION.dup

  spec.summary       = "Validation library"
  spec.description   = spec.summary
  spec.homepage      = "https://dry-rb.org/gems/dry-validation"
  spec.files         = Dir["CHANGELOG.md", "LICENSE", "README.md", "dry-validation.gemspec",
                           "lib/**/*", "config/*.yml"]
  spec.bindir        = "bin"
  spec.executables   = []
  spec.require_paths = ["lib"]

  spec.metadata["allowed_push_host"]     = "https://rubygems.org"
  spec.metadata["changelog_uri"]         = "https://github.com/dry-rb/dry-validation/blob/main/CHANGELOG.md"
  spec.metadata["source_code_uri"]       = "https://github.com/dry-rb/dry-validation"
  spec.metadata["bug_tracker_uri"]       = "https://github.com/dry-rb/dry-validation/issues"
  spec.metadata["rubygems_mfa_required"] = "true"

  spec.required_ruby_version = ">= 3.1"

  # to update dependencies edit project.yml
  spec.add_dependency "concurrent-ruby", "~> 1.0"
  spec.add_dependency "dry-core", "~> 1.1"
  spec.add_dependency "dry-initializer", "~> 3.2"
  spec.add_dependency "dry-schema", "~> 1.14"
  spec.add_dependency "zeitwerk", "~> 2.6"
end
