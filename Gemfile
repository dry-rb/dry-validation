# frozen_string_literal: true

source 'https://rubygems.org'

gemspec

git_source(:github) { |repo_name| "https://github.com/dry-rb/#{repo_name}" }

if ENV['USE_SCHEMA_MASTER'].eql?('true')
  gem 'dry-schema', github: 'dry-schema', branch: 'master'
end

group :test do
  gem 'dry-monads', '~> 1.0'
  gem 'i18n', require: false
  gem 'simplecov', require: false, platform: :mri
end

group :tools do
  gem 'pry', platform: :jruby
  gem 'pry-byebug', platform: :mri
end

group :benchmarks do
  gem 'actionpack'
  gem 'activemodel'
  gem 'activerecord'
  gem 'benchmark-ips'
  gem 'hotch', platform: :mri
  gem 'sqlite3'
  gem 'virtus'
end
