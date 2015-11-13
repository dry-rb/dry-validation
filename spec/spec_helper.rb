# encoding: utf-8

require 'faker'
require 'dry-validation'

Dir[Pathname(__FILE__).dirname.join('support/**/*.rb')].each(&method(:require))
