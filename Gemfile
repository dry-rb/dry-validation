# frozen_string_literal: true

source "https://rubygems.org"

eval_gemfile "Gemfile.devtools"

gemspec

# if ENV["DRY_CONFIGURABLE_FROM_MAIN"].eql?("true")
#   gem "dry-configurable", github: "dry-rb/dry-configurable", branch: "main"
# end

gem "dry-configurable", github: "dry-rb/dry-configurable", branch: "main"
gem "dry-core", github: "dry-rb/dry-core", branch: "main"
gem "dry-logic", github: "dry-rb/dry-logic", branch: "main"

# if ENV["DRY_SCHEMA_FROM_MAIN"].eql?("true")
#   gem "dry-schema", github: "dry-rb/dry-schema", branch: "main"
# end

gem "dry-schema", github: "dry-rb/dry-schema", branch: "main"

# if ENV["DRY_TYPES_FROM_MAIN"].eql?("true")
#   gem "dry-types", github: "dry-rb/dry-types", branch: "main"
# end

gem "dry-types", github: "dry-rb/dry-types", branch: "main"

group :test do
  gem "dry-monads", github: "dry-rb/dry-monads", branch: "main"
  gem "i18n", require: false
end

group :tools do
  gem "pry", platform: :jruby
  gem "pry-byebug", platform: :mri
end

group :benchmarks do
  gem "actionpack"
  gem "activemodel"
  gem "activerecord"
  gem "benchmark-ips"
  gem "hotch", platform: :mri
  gem "sqlite3"
  gem "virtus"
end
