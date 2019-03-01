require 'dry/validation/contract'

RSpec.describe Dry::Validation::Contract, '.json' do
  subject(:contract) do
    Class.new(Dry::Validation::Contract) do
      json do
        required(:email).filled(:string)
      end
    end
  end

  it 'calls Dry::Scheme.JSON' do
    expect(Dry::Schema).to receive(:JSON)
    contract.new
  end
end
