source 'https://rubygems.org'

gemspec

gem 'dry-types', github: 'dry-rb/dry-types', branch: 'master'
gem "dry-logic", github: 'dry-rb/dry-logic', branch: 'master'

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
  gem 'activemodel', '~> 5.0.0.rc'
  gem 'actionpack', '~> 5.0.0.rc'
  gem 'benchmark-ips'
  gem 'virtus'
end
