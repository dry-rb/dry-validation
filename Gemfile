# frozen_string_literal: true

source 'https://rubygems.org'

gemspec

git_source(:github) { |repo_name| "https://github.com/#{repo_name}" }

gem 'dry-schema', github: 'dry-rb/dry-schema', branch: 'custom-messages'

group :test do
  gem 'dry-monads', '~> 1.0'
  gem 'i18n', require: false
  gem 'simplecov', require: false, platform: :mri
end

group :tools do
  gem 'pry-byebug', platform: :mri
  gem 'pry', platform: :jruby
end

group :benchmarks do
  gem 'benchmark-ips'
  gem 'hotch', platform: :mri
  gem 'activemodel'
  gem 'actionpack'
  gem 'virtus'
end
