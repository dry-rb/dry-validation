source 'https://rubygems.org'

gemspec

group :test do
  gem 'i18n', require: false
  platform :mri do
    gem 'codeclimate-test-reporter', require: false
    gem 'simplecov', require: false
  end
  gem 'dry-monads', require: false
  gem 'dry-struct', require: false
end

group :tools do
  gem 'byebug', platform: :mri
  gem 'pry'

  unless ENV['TRAVIS']
    gem 'mutant', github: 'mbj/mutant'
    gem 'mutant-rspec', github: 'mbj/mutant'
  end
end

group :benchmarks do
  gem 'hotch', platform: :mri
  gem 'activemodel', '~> 5.0.0.rc'
  gem 'actionpack', '~> 5.0.0.rc'
  gem 'benchmark-ips'
  gem 'virtus'
end
