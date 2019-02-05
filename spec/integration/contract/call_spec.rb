require 'dry/validation/contract'

RSpec.describe Dry::Validation::Contract, '#call' do
  subject(:contract) do
    Class.new(Dry::Validation::Contract) do
      params do
        required(:email).filled(:string)
        required(:age).filled(:integer)
        optional(:login).maybe(:string, :filled?)
        optional(:password).maybe(:string, min_size?: 10)
        optional(:password_confirmation).maybe(:string)
      end

      rule(:password, :login) do
        if params[:login] && !params[:password]
          failure("is required")
        end
      end

      rule(:age) do
        if params[:age] < 18
          failure("must be greater or equal 18")
        end
      end
    end.new
  end

  it "applies rule to input processed by the schema" do
    result = contract.(email: "john@doe.org", age: 19)

    expect(result).to eql({})
  end

  it "returns rule errors" do
    result = contract.(email: "john@doe.org", login: "jane", age: 19)

    expect(result).to eql(password: ["is required"])
  end

  it "doesn't execute rules when basic checks failed" do
    result = contract.(email: "john@doe.org", age: "not-an-integer")

    expect(result).to eql(age: ["must be an integer"])
  end
end
