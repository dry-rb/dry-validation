# frozen_string_literal: true

# this file is managed by dry-rb/devtools project

require "warning"

Warning.ignore(%r{rspec/core})
Warning.ignore(%r{rspec/mocks})
Warning.ignore(/codacy/)
Warning[:experimental] = false if Warning.respond_to?(:[])

if Gem::Version.new(RUBY_VERSION) >= Gem::Version.new("3.4")
  Warning[:strict_unused_block] = true
end
