# frozen_string_literal: true

require "dry-validation"

contract = Class.new(Dry::Validation::Contract) do
  schema do
    required(:email).filled
  end

  def self.messages
    super.merge(en: {
                  dry_validation: {
                    errors: {
                      rules: {
                        email: {
                          john?: "%{value} is not a john email",
                          example?: "%{value} is not an example email"
                        }
                      }
                    }
                  }
                })
  end

  rule(:email) do
    key.failure(:example?, value: value) unless value.end_with?("@example.com")

    key.failure(:john?, value: value) unless value.start_with?("john")
  end
end.new

result = contract.call(email: "jane@doe.org")

puts result.inspect
