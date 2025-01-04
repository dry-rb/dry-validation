# frozen_string_literal: true

require_relative "support/coverage"
require_relative "support/warnings"
require_relative "support/rspec_options"

begin
  require "pry"
  require "pry-byebug"
rescue LoadError
end

Warning.process { |w| raise w }

require "yaml"
require "i18n"
require "dry/validation"

SPEC_ROOT = Pathname(__dir__)

Dir[SPEC_ROOT.join("support/**/*.rb")].each(&method(:require))

RSpec.configure do |config|
  config.before do
    stub_const("Test", Module.new)
  end

  config.after do
    I18n.load_path = [Dry::Schema::DEFAULT_MESSAGES_PATH]
    I18n.locale = :en
    I18n.reload!
  end
end
