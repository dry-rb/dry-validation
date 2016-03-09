require 'dry-validation'

schema = Dry::Validation.Form do
  key(:email).required

  key(:age).required(:int?, gt?: 18)
end

errors = schema.call('email' => '', 'age' => '18').messages

puts errors.inspect
