# frozen_string_literal: true

source 'https://rubygems.org'

gemspec

gem 'dry-schema', git: 'https://github.com/dry-rb/dry-schema', branch: 'master'

group :test do
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
