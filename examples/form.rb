require 'dry-validation'

schema = Dry::Validation.Form do
  required(:email).not_nil

  required(:age).not_nil(:int?, gt?: 18)
end

errors = schema.call('email' => '', 'age' => '18').messages

puts errors.inspect
