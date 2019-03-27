# frozen_string_literal: true

require_relative 'suite'

class TestContract < Dry::Validation::Contract
  config.messages.backend = :i18n

  params do
    required(:email).filled(:string)
    required(:age).filled(:integer)
    required(:address).filled(:hash)
  end

  rule(:age) do
    key.failure('must be greater than 18') if values[:age] <= 18
  end
end

contract = TestContract.new
input = { email: '', age: 18, address: {} }

profile do
  10_000.times do
    contract.(input)
  end
end
