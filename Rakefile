#!/usr/bin/env rake
# frozen_string_literal: true

require 'bundler/gem_tasks'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), 'lib'))

require 'rspec/core'
require 'rspec/core/rake_task'

require 'dry/validation'

RSpec::Core::RakeTask.new(:spec)

extensions = Dir['./spec/extensions/*'].map { |path| Pathname(path).basename.to_s.to_sym }

desc 'Run only core specs without extensions specs'
RSpec::Core::RakeTask.new('spec:core') do |t|
  t.rspec_opts = 'spec/unit spec/integration --pattern **/*_spec.rb'
end

extensions.each do |ext|
  desc "Run all specs with #{ext} enabled"
  RSpec::Core::RakeTask.new("spec:#{ext}") do |t|
    puts "Running specs with #{ext.inspect} enabled"

    Dry::Validation.load_extensions(ext)

    t.rspec_opts = "spec/unit spec/integration spec/extensions/#{ext} --pattern **/*_spec.rb"
  end
end

desc 'Run all specs with all extensions enabled'
task 'spec:extensions' do
  puts "Loading extensions: #{extensions.inspect}"

  Dry::Validation.load_extensions(*extensions)
  Rake::Task[:spec].invoke
end

desc 'Run all specs in isolation with extension enabled'
task 'spec:isolation' => ['spec:core', *extensions.map { |ext| "spec:#{ext}" }]

desc 'Run CI build'
task ci: %w[spec:core spec:isolation spec:extensions]

task default: :ci
