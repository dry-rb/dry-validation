require 'dry/validation/contract'

RSpec.describe Dry::Validation::Contract, '.json' do
  subject(:contract) do
    Class.new(Dry::Validation::Contract) do
      json do
        required(:email).filled(:string)
      end
    end
  end

  it 'defines a JSON schema' do
    expect(contract.__schema__).to be_a(Dry::Schema::JSON)
  end
end
