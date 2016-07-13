source 'https://rubygems.org'

gemspec

gem 'dry-types', github: 'dry-rb/dry-types', branch: 'master'

group :test do
  gem 'i18n', require: false
  gem 'codeclimate-test-reporter', platform: :rbx
end

group :tools do
  gem 'byebug', platform: :mri
  gem 'pry'
end

group :benchmarks do
  gem 'hotch', platform: :mri
  gem 'activemodel', '~> 5.0.0.rc'
  gem 'actionpack', '~> 5.0.0.rc'
  gem 'benchmark-ips'
  gem 'virtus'
end
