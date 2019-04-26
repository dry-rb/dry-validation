#!/usr/bin/env rake
# frozen_string_literal: true

require 'bundler/gem_tasks'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), 'lib'))

require 'rspec/core'
require 'rspec/core/rake_task'

desc 'Run all specs in spec directory'
task :spec do
  core_result = RSpec::Core::Runner.run(['spec/integration'])

  RSpec.clear_examples

  ext_results = Dir[SPEC_ROOT.join('extensions/*')].map do |path|
    ext = Pathname(path).basename.to_s.to_sym

    puts "=> Running spec suite with #{ext.inspect} enabled"

    Dry::Validation.load_extensions(ext)
    RSpec::Core::Runner.run(['spec'])
  end

  exit [core_result, *ext_results].max
end

task default: :spec
