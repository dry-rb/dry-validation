# frozen_string_literal: true

# this file is managed by dry-rb/devtools

if ENV["COVERAGE"] == "true"
  require "simplecov"
  require "simplecov-cobertura"

  SimpleCov.formatter = SimpleCov::Formatter::CoberturaFormatter

  SimpleCov.start do
    add_filter "/spec/"
    enable_coverage :branch
  end
end
