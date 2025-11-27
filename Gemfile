# frozen_string_literal: true

source "https://rubygems.org"

eval_gemfile "Gemfile.devtools"

gemspec

group :test do
  gem "dry-monads"
  gem "i18n", require: false
end

group :benchmarks do
  gem "actionpack"
  gem "activemodel"
  gem "activerecord"
  gem "benchmark-ips"
  # gem "hotch", platform: :mri
  gem "sqlite3", platform: :mri
  gem "jdbc-sqlite3", platform: :jruby
  gem "activerecord-jdbc-adapter", platform: :jruby
  gem "virtus"
end
