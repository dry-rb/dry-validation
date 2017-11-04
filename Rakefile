#!/usr/bin/env rake
require 'bundler/gem_tasks'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), 'lib'))

require 'rspec/core'
require 'rspec/core/rake_task'

desc 'Run all specs in spec directory'
task :run_specs do
  core_result = RSpec::Core::Runner.run(['spec/integration', 'spec/unit'])
  RSpec.clear_examples

  Dir[SPEC_ROOT.join('shared/**/*.rb')].each(&method(:load))

  Dry::Validation.load_extensions(:monads, :struct)
  ext_result = RSpec::Core::Runner.run(['spec'])

  exit [core_result, ext_result].max
end

task default: :run_specs
