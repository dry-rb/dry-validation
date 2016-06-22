require_relative 'suite'
require 'hotch'

schema = Dry::Validation.Schema do
  configure { config.messages = :i18n }

  required(:email).filled
  required(:age).filled(:int?, gt?: 18)
  required(:address).filled(:hash?)
end

puts schema.(email: 'jane@doe.org', age: 19, address: { city: 'Krakow' }).inspect

Hotch() do
  10_000.times do
    schema.(email: 'jane@doe.org', age: 18, address: { city: 'Krakow' })
  end
end
