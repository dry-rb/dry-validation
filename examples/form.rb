require 'dry-validation'
require 'dry/validation/schema/form'

class UserFormSchema < Dry::Validation::Schema::Form
  key(:email) { |value| value.str? & value.filled? }

  key(:age) { |value| value.int? & value.gt?(18) }
end

schema = UserFormSchema.new

errors = schema.messages('email' => '', 'age' => '18')

puts errors.inspect
# [[:email, ["email must be filled"]], [:age, ["age must be greater than 18 (18 was given)"]]]
