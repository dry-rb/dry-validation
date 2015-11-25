require 'dry-validation'

class Schema < Dry::Validation::Schema
  key(:email) { |email| email.filled? }

  key(:age) do |age|
    age.int? & age.gt?(18)
  end
end

schema = Schema.new

errors = schema.messages(email: 'jane@doe.org', age: 19)

puts errors.inspect
# []

errors = schema.messages(email: nil, age: 19)

puts errors.inspect
# [[:email, ["email must be filled"]]]
