source 'https://rubygems.org'

git_source(:github) { |repo_name| "https://github.com/#{repo_name}" }

gemspec

gem 'dry-types', github: 'dry-rb/dry-types', branch: 'rework-schemas'

group :test do
  gem 'i18n', require: false
  platform :mri do
    gem 'simplecov', require: false
  end
  gem 'dry-monads', '>= 0.4.0', require: false
  gem 'dry-struct', github: 'dry-rb/dry-struct', branch: 'update-schemas'
end

group :tools do
  gem 'pry-byebug', platform: :mri
  gem 'pry', platform: :jruby

  unless ENV['TRAVIS']
    gem 'mutant', git: 'https://github.com/mbj/mutant'
    gem 'mutant-rspec', git: 'https://github.com/mbj/mutant'
  end
end

group :benchmarks do
  gem 'hotch', platform: :mri
  gem 'activemodel', '~> 5.0.0.rc'
  gem 'actionpack', '~> 5.0.0.rc'
  gem 'benchmark-ips'
  gem 'virtus'
end
