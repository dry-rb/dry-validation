source 'https://rubygems.org'

gemspec

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

gem "dry-logic", git: 'https://github.com/dry-rb/dry-logic.git', branch: "master"
gem "dry-types", git: 'https://github.com/dry-rb/dry-types.git', branch: "dry_logic_predicate_change"