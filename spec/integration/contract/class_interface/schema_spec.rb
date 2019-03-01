require 'dry/validation/contract'

RSpec.describe Dry::Validation::Contract, '.params' do
  subject(:contract) do
    Class.new(Dry::Validation::Contract) do
      schema do
        required(:email).filled(:string)
      end
    end
  end

  it 'calls Dry::Scheme.Params' do
    expect(Dry::Schema).to receive(:define)
    contract.new
  end
end
