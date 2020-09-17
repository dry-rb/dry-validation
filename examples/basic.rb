# frozen_string_literal: true

require "dry-validation"

contract = Class.new(Dry::Validation::Contract) do
  schema do
    required(:email).filled

    required(:age).filled(:int?, gt?: 18)
  end
end.new

errors = contract.call(email: "jane@doe.org", age: 19)

puts errors.inspect

errors = contract.call(email: nil, age: 19)

puts errors.inspect
