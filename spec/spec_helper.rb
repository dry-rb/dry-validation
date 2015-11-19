# encoding: utf-8

require 'faker'
require 'dry-validation'

begin
  require 'byebug'
rescue LoadError; end

Dir[Pathname(__FILE__).dirname.join('shared/**/*.rb')].each(&method(:require))
Dir[Pathname(__FILE__).dirname.join('support/**/*.rb')].each(&method(:require))
