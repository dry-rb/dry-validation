# frozen_string_literal: true

source "https://rubygems.org"

eval_gemfile "Gemfile.devtools"

gemspec

gem "dry-types", github: "dry-rb/dry-types"

group :test do
  gem "dry-monads", github: "dry-rb/dry-monads"
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
