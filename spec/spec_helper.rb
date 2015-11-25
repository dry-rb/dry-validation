# encoding: utf-8

require 'dry-validation'

begin
  require 'byebug'
rescue LoadError; end

Dir[Pathname(__FILE__).dirname.join('shared/**/*.rb')].each(&method(:require))
Dir[Pathname(__FILE__).dirname.join('support/**/*.rb')].each(&method(:require))

include Dry::Validation

RSpec.configure do |config|
  config.disable_monkey_patching!
end
