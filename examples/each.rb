# frozen_string_literal: true

require "byebug"
require "dry-validation"

schema = Dry::Validation.Schema do
  key(:phone_numbers).each(:str?)
end

errors = schema.call(phone_numbers: "").messages

puts errors.inspect

errors = schema.call(phone_numbers: ["123456789", 123_456_789]).messages

puts errors.inspect
