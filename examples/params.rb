require 'dry-validation'

contract = Class.new(Dry::Validation::Contract) do
  params do
    required(:email).filled
    required(:age).filled(:int?, gt?: 18)
  end
end.new

result = contract.('email' => '', 'age' => '19')

puts result.inspect
