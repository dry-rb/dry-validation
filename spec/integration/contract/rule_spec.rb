require 'dry/validation/contract'

RSpec.describe Dry::Validation::Contract, '.rule' do
  subject(:contract) do
    Class.new(Dry::Validation::Contract) do
      params do
        required(:email).filled(:string)
      end

      rule(:email) do
        value = params[:email]
        failure('is invalid') unless value.include?('@')
      end

      rule('email') do
        value = params[:email]
        failure("should be in 'dry-rb.org' domain") if value.split('@').last != 'dry-rb.org'
      end
    end.new
  end

  it "allows combines rules with the same name into one" do
    result = contract.(email: "jane")

    expect(result.errors).to eql(email: ["is invalid", "should be in 'dry-rb.org' domain"])
  end
end
