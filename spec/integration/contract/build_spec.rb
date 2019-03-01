require 'dry/validation/contract'

RSpec.describe Dry::Validation::Contract, '.build' do
  subject(:contract) do
    Dry::Validation::Contract.build do
      params do
        required(:email).filled(:string)
      end
    end
  end

  it "return instance of Dry::Validation::Contract" do
    expect(contract).to be_a(Dry::Validation::Contract)
  end
end
