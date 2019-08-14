# frozen_string_literal: true

require 'dry/validation/contract'

RSpec.describe Dry::Validation::Contract, '.rule' do
  subject(:contract) { contract_class.new }

  context 'with a nested hash' do
    let(:contract_class) do
      Class.new(Dry::Validation::Contract) do
        params do
          required(:email).filled(:string)
          required(:address).hash do
            required(:city).value(:string)
            required(:street).value(:string)
            required(:zipcode).value(:string)
          end
        end

        rule(:email) do
          key.failure('invalid email') unless value.include?('@')
        end

        rule('address.zipcode') do
          key.failure('bad format') unless value.include?('-')
        end
      end
    end

    context 'when nested values fail both schema and rule checks' do
      it 'produces schema and rule errors' do
        expect(contract.(email: 'jane@doe.org', address: { city: 'NYC', zipcode: '123' }).errors.to_h)
          .to eql(address: { street: ['is missing'], zipcode: ['bad format'] })
      end
    end

    context 'when empty hash is provided' do
      it 'produces missing-key errors' do
        expect(contract.({}).errors.to_h).to eql(email: ['is missing'], address: ['is missing'])
      end
    end
  end

  context 'with a rule that depends on two nested values' do
    let(:contract_class) do
      Class.new(Dry::Validation::Contract) do
        params do
          required(:event).schema do
            required(:active_from).value(:date)
            required(:active_until).value(:date)
          end
        end

        rule(event: %i[active_from active_until]) do
          key.failure('invalid dates') if value[0] < value[1]
        end
      end
    end

    it 'does not execute rule when the schema checks failed' do
      result = contract.(event: { active_from: Date.today, active_until: nil })

      expect(result.errors.to_h).to eql(event: { active_until: ['must be a date'] })
    end
  end

  context 'with a nested array' do
    let(:contract_class) do
      Class.new(Dry::Validation::Contract) do
        params do
          required(:address).hash do
            required(:phones).array(:string)
          end
        end

        rule('address.phones').each do
          key.failure('invalid phone') unless value.start_with?('+48')
        end
      end
    end

    context 'when one of the values fails' do
      it 'produces an error for the invalid value' do
        expect(contract.(address: { phones: ['+48123', '+47412', nil] }).errors.to_h)
          .to eql(address: { phones: { 1 => ['invalid phone'], 2 => ['must be a string'] } })
      end
    end
  end
end
