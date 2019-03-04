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
    expect(contract_class.__schema__).to be_a(Dry::Schema::JSON)
  end

  it 'raises an error if schema is already defined' do
    expect do
      contract_class.json do
        required(:login).filled(:string)
      end
    end.to raise_error Dry::Validation::DuplicateSchemaError
  end
end
