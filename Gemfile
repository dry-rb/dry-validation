source 'https://rubygems.org'

gemspec

gem 'dry-types', github: 'dryrb/dry-types', branch: 'master'
gem 'dry-logic', github: 'dryrb/dry-logic', branch: 'master'

group :test do
  gem 'i18n'
  gem 'codeclimate-test-reporter', platform: :rbx
end

group :tools do
  gem 'guard'
  gem 'guard-rspec'
  gem 'guard-rubocop'
  gem 'byebug', platform: :mri
end

group :benchmarks do
  gem 'hotch'
  gem 'activemodel'
  gem 'benchmark-ips'
  gem 'virtus'
end
