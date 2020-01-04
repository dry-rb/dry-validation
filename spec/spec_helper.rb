# frozen_string_literal: true

require_relative 'support/coverage'

begin
  require 'pry'
  require 'pry-byebug'
rescue LoadError
end

require 'i18n'
require 'dry/validation'

SPEC_ROOT = Pathname(__dir__)

Dir[SPEC_ROOT.join('shared/**/*.rb')].each(&method(:require))
Dir[SPEC_ROOT.join('support/**/*.rb')].each(&method(:require))

RSpec.configure do |config|
  config.disable_monkey_patching!
  config.warnings = true

  config.before do
    module Test
      def self.remove_constants
        constants.each { |const| remove_const(const) }
        self
      end
    end
  end

  config.after do
    Object.send(:remove_const, Test.remove_constants.name)

    I18n.load_path = [Dry::Schema::DEFAULT_MESSAGES_PATH]
    I18n.locale = :en
    I18n.reload!
  end
end
