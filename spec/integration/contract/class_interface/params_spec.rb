require 'dry/validation/contract'

RSpec.describe Dry::Validation::Contract, '.params' do
  subject(:contract) do
    Class.new(Dry::Validation::Contract) do
      params do
        required(:email).filled(:string)
      end
    end
  end

  it 'calls Dry::Scheme.Params' do
    expect(Dry::Schema).to receive(:Params)
    contract.new
  end
end
