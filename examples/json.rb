require 'json'
require 'dry-validation'

contract = Class.new(Dry::Validation::Contract) do
  json do
    required(:email).filled
    required(:age).filled(:int?, gt?: 18)
  end
end.new

result = contract.call(JSON.parse('{"email": "", "age": "18"}'))

puts result.inspect
