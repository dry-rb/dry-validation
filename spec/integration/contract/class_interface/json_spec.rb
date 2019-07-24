# frozen_string_literal: true

require 'dry/validation/contract'

RSpec.describe Dry::Validation::Contract, '.json' do
  subject(:contract_class) do
    Class.new(Dry::Validation::Contract) do
      json do
        required(:email).filled(:string)
      end
    end
  end

  it 'defines a JSON schema' do
    expect(contract_class.schema).to be_a(Dry::Schema::JSON)
    expect(contract_class.json).to be_a(Dry::Schema::JSON)

    expect(contract_class.schema).to be(contract_class.json)
  end

  it 'returns nil if schema is not defined' do
    contract_class = Class.new(Dry::Validation::Contract)
    expect(contract_class.schema).to be(nil)
  end

  it 'raises an error if schema is already defined' do
    expect do
      contract_class.json do
        required(:login).filled(:string)
      end
    end.to raise_error Dry::Validation::DuplicateSchemaError
  end
end
