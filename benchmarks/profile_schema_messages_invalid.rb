require_relative 'suite'
require 'hotch'

schema = Dry::Validation.Schema do
  configure { config.messages = :i18n }

  required(:email).filled
  required(:age).filled(:int?, gt?: 18)
  required(:address).filled(:hash?)
end

input = { email: '', age: 18, address: {} }

puts schema.(input).inspect

Hotch() do
  10_000.times do
    schema.(input).messages
  end
end
