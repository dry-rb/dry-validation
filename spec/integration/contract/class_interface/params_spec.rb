# frozen_string_literal: true

require 'dry/validation/contract'

RSpec.describe Dry::Validation::Contract, '.params' do
  subject(:contract_class) do
    Class.new(Dry::Validation::Contract) do
      params do
        required(:email).filled(:string)
      end
    end
  end

  it 'defines a Params schema' do
    expect(contract_class.schema).to be_a(Dry::Schema::Params)
    expect(contract_class.params).to be_a(Dry::Schema::Params)

    expect(contract_class.schema).to be(contract_class.params)
  end

  it 'returns nil if schema is not defined' do
    contract_class = Class.new(Dry::Validation::Contract)
    expect(contract_class.schema).to be(nil)
  end

  it 'raises an error if schema is already defined' do
    expect do
      contract_class.params do
        required(:login).filled(:string)
      end
    end.to raise_error Dry::Validation::DuplicateSchemaError
  end
end
