# frozen_string_literal: true

require 'dry/validation/contract'

RSpec.describe Dry::Validation::Contract, '.rule' do
  subject(:contract) { contract_class.new }

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
end
