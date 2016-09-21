source 'https://rubygems.org'

gemspec

group :test do
  gem 'i18n', require: false
  gem 'codeclimate-test-reporter', platform: :rbx
  gem 'dry-monads', require: false
  gem 'dry-struct', github: 'dry-rb/dry-struct', branch: 'master', require: false
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
