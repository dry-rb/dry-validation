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
  gem "sqlite3"
  gem "virtus"
end
