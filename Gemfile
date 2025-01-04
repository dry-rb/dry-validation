# frozen_string_literal: true

source "https://rubygems.org"

eval_gemfile "Gemfile.devtools"

gemspec

gem "dry-configurable", github: "dry-rb/dry-configurable", branch: "main"
gem "dry-core", github: "dry-rb/dry-core", branch: "main"
gem "dry-schema", github: "dry-rb/dry-schema", branch: "main"
gem "dry-types", github: "dry-rb/dry-types", branch: "main"

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
