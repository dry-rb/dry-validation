source 'https://rubygems.org'

gemspec

gem 'dry-types', github: 'dry-rb/dry-types', branch: 'master'
gem "dry-logic", github: 'dry-rb/dry-logic', branch: 'predicate_params_airity'

group :test do
  gem 'i18n'
  gem 'codeclimate-test-reporter', platform: :rbx
end

group :tools do
  gem 'byebug', platform: :mri
  gem 'pry'
end

group :benchmarks do
  gem 'hotch'
  gem 'activemodel', '5.0.0.beta3'
  gem 'actionpack', '5.0.0.beta3'
  gem 'benchmark-ips'
  gem 'virtus'
end
