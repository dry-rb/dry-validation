require 'dry-validation'

schema = Dry::Validation.Schema do
  configure do
    def self.messages
      super.merge(en: {
        errors: {
          john_email?: '%{value} is not a john email',
          example_email?: '%{value} is not a example email'
        } })
    end
  end

  required(:email).filled

  validate(example_email?: :email) do |value|
    value.end_with?('@example.com')
  end

  validate(john_email?: :email) do |value|
    value.start_with?('john')
  end
end

errors = schema.call(email: 'jane@doe.org').messages

puts errors.inspect
