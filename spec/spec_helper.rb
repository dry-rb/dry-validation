# encoding: utf-8

require 'dry-validation'

begin
  require 'byebug'
rescue LoadError; end

SPEC_ROOT = Pathname(__dir__)

Dir[SPEC_ROOT.join('shared/**/*.rb')].each(&method(:require))
Dir[SPEC_ROOT.join('support/**/*.rb')].each(&method(:require))

include Dry::Validation

RSpec.configure do |config|
  config.disable_monkey_patching!

  config.after do
    if defined?(I18n)
      I18n.load_path = Dry::Validation.messages_paths.dup
      I18n.backend.reload!
    end
  end
end
