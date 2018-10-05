source 'https://rubygems.org'

gemspec

gem 'dry-logic', git: 'https://github.com/dry-rb/dry-logic', branch: 'master'
gem 'dry-schema', git: 'https://github.com/dry-rb/dry-schema', branch: 'master'

group :test do
  gem 'i18n', require: false

  platform :mri do
    gem 'simplecov', require: false
  end

  gem 'dry-monads', '>= 0.4.0', require: false
  gem 'dry-struct', git: 'https://github.com/dry-rb/dry-struct', branch: 'master'
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
