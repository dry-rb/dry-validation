# frozen_string_literal: true

require "dry-validation"

contract = Class.new(Dry::Validation::Contract) do
  schema do
    required(:address).schema do
      required(:city).filled(min_size?: 3)

      required(:street).filled

      required(:country).schema do
        required(:name).filled
        required(:code).filled
      end
    end
  end
end.new

errors = contract.call({})

puts errors.inspect

errors = contract.call(address: {city: "NYC"})

puts errors.inspect
