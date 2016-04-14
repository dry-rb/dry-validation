require 'dry-validation'

schema = Dry::Validation.Form do
  required(:email).required

  required(:age).required(:int?, gt?: 18)
end

errors = schema.call('email' => '', 'age' => '18').messages

puts errors.inspect
