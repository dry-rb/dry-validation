require 'dry-validation'

class Schema < Dry::Validation::Schema
  key(:email) { |email| email.filled? }

  key(:age) do |age|
    age.int? & age.gt?(18)
  end
end

schema = Schema.new

errors = schema.call(email: 'jane@doe.org', age: 19).messages

puts errors.inspect

errors = schema.call(email: nil, age: 19).messages

puts errors.inspect
