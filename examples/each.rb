require 'dry-validation'

class Schema < Dry::Validation::Schema
  key(:phone_numbers) do |phone_numbers|
    phone_numbers.array? do
      phone_numbers.each(&:str?)
    end
  end
end

schema = Schema.new

errors = schema.messages(phone_numbers: '')

puts errors.inspect

errors = schema.messages(phone_numbers: ['123456789', 123456789])

puts errors.inspect
