# frozen_string_literal: true

require 'dry/validation/contract'

RSpec.describe Dry::Validation, '.Contract' do
  subject(:contract) do
    Dry::Validation.Contract do
      params do
        required(:email).filled(:string)
      end
    end
  end

  it 'returns an instance of Dry::Validation::Contract' do
    expect(contract).to be_a(Dry::Validation::Contract)
  end
end
