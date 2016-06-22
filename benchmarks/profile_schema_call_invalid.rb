require_relative 'suite'
require 'hotch'

schema = Dry::Validation.Schema do
  configure { config.messages = :i18n }

  required(:email).filled
  required(:age).filled(:int?, gt?: 18)
  required(:address).filled(:hash?)
end

puts schema.(email: '', age: 18, address: {}).inspect

Hotch() do
  1000.times do
    schema.(email: '', age: 18, address: {})
  end
end
