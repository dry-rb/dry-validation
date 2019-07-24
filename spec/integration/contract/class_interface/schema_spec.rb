# frozen_string_literal: true

require 'dry/validation/contract'

RSpec.describe Dry::Validation::Contract, '.schema' do
  subject(:contract_class) do
    Class.new(Dry::Validation::Contract) do
      schema do
        required(:email).filled(:string)
      end
    end
  end

  it 'defines a schema' do
    expect(contract_class.schema).to be_a(Dry::Schema::Processor)
  end

  it 'returns nil if schema is not defined' do
    contract_class = Class.new(Dry::Validation::Contract)
    expect(contract_class.schema).to be(nil)
  end

  it 'raises an error if schema is already defined' do
    expect do
      contract_class.schema do
        required(:login).filled(:string)
      end
    end.to raise_error Dry::Validation::DuplicateSchemaError
  end
end
