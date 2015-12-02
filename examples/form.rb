require 'dry-validation'
require 'dry/validation/schema/form'

class UserFormSchema < Dry::Validation::Schema::Form
  key(:email) { |value| value.str? & value.filled? }

  key(:age) { |value| value.int? & value.gt?(18) }
end

schema = UserFormSchema.new

errors = schema.call('email' => '', 'age' => '18').messages

puts errors.inspect
