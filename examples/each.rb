# frozen_string_literal: true

require "dry-validation"

contract = Class.new(Dry::Validation::Contract) do
  schema do
    required(:phone_numbers).value(:array).each(:string)
  end
end.new

errors = contract.call(phone_numbers: "")

puts errors.inspect

errors = contract.call(phone_numbers: ["123456789", 123_456_789])

puts errors.inspect
