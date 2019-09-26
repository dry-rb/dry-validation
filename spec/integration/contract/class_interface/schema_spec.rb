# frozen_string_literal: true

require 'dry/validation/contract'

RSpec.describe Dry::Validation::Contract, '.schema' do
  context 'defining a schema via block' do
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

  context 'setting an external schema' do
    subject(:contract_class) do
      Class.new(Dry::Validation::Contract) do
        schema(Test::UserSchema) do
          required(:name).filled(:string)
        end
      end
    end

    before do
      Test::UserSchema = Dry::Schema.Params do
        required(:email).filled(:string)
      end
    end

    it 'defines a schema' do
      expect(contract_class.schema).to be_a(Dry::Schema::Processor)
    end

    it 'extends the schema' do
      contract = contract_class.new

      expect(contract.(email: '', name: '').errors.to_h)
        .to eql(email: ['must be filled'], name: ['must be filled'])
    end

    context 'schema without block argument' do
      subject(:contract_class) do
        Class.new(Dry::Validation::Contract) do
          schema Test::UserSchema
        end
      end

      it 'uses the external schema' do
        expect(contract_class.schema).to be_a(Dry::Schema::Processor)
      end
    end

    context 'setting multiple external schemas' do
      subject(:contract_class) do
        Class.new(Dry::Validation::Contract) do
          schema(Test::UserSchema, Test::CompanySchema) do
            required(:name).filled(:string)
          end
        end
      end

      before do
        Test::CompanySchema = Dry::Schema.Params do
          required(:company).filled(:string)
        end
      end

      it 'extends the schemas' do
        contract = contract_class.new
        expect(contract.(email: '', name: '', company: '').errors.to_h)
          .to eql(email: ['must be filled'],
                  name: ['must be filled'],
                  company: ['must be filled'])
      end
    end
  end
end
