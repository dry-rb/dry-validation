# encoding: utf-8

begin
  require 'byebug'
rescue LoadError; end

if RUBY_ENGINE == "rbx"
  require "codeclimate-test-reporter"
  CodeClimate::TestReporter.start
end

require 'dry-validation'

SPEC_ROOT = Pathname(__dir__)

Dir[SPEC_ROOT.join('shared/**/*.rb')].each(&method(:require))
Dir[SPEC_ROOT.join('support/**/*.rb')].each(&method(:require))

include Dry::Validation

class Schema::Value < BasicObject
  def inspect
    to_ast.inspect
  end
end

class Schema::Key < BasicObject
  def inspect
    to_ast.inspect
  end
end

class Schema::Rule < BasicObject
  def inspect
    to_ast.inspect
  end
end

RSpec.configure do |config|
  config.disable_monkey_patching!

  config.after do
    if defined?(I18n)
      I18n.load_path = Dry::Validation.messages_paths.dup
      I18n.backend.reload!
    end
  end
end
