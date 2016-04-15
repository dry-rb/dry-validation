require 'json'
require 'dry-validation'

schema = Dry::Validation.JSON do
  required(:email).filled

  required(:age).filled(:int?, gt?: 18)
end

errors = schema.call(JSON.parse('{"email": "", "age": "18"}')).messages

puts errors.inspect
