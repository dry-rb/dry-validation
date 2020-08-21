# frozen_string_literal: true

require "dry-validation"

contract = Class.new(Dry::Validation::Contract) do
  params do
    required(:email).filled(:string)
    required(:age).filled(:integer, gt?: 18)
  end
end.new

result = contract.("email" => "", "age" => "19")

puts result.inspect
