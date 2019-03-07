# frozen_string_literal: true

require 'dry/validation/contract'

RSpec.describe Dry::Validation::Contract, '.rule' do
  subject(:contract) { contract_class.new }

  let(:contract_class) do
    Class.new(Dry::Validation::Contract) do
      params do
        required(:email).filled(:string)
        optional(:login).filled(:string)

        optional(:address).hash do
          required(:street).value(:string)
        end
      end
    end
  end

  context 'when the name matches one of the keys' do
    before do
      contract_class.rule(:login) do
        failure('is too short') if values[:login].size < 3
      end
    end

    it 'applies rule when value passed schema checks' do
      expect(contract.(email: 'jane@doe.org', login: 'ab').errors).to eql(login: ['is too short'])
    end
  end

  context 'when the name does not match one of the keys' do
    before do
      contract_class.rule(:custom) do
        failure('this works')
      end
    end

    it 'applies the rule regardless of the schema result' do
      expect(contract.(email: 'jane@doe.org', login: 'jane').errors).to eql(custom: ['this works'])
    end
  end

  context 'with a hash as the key identifier' do
    before do
      contract_class.rule(address: :street) do
        failure('cannot be empty') if values[:address][:street].strip.empty?
      end
    end

    it 'applies the rule when nested value passed schema checks' do
      expect(contract.(email: 'jane@doe.org', login: 'jane', address: nil).errors)
        .to eql(address: ['must be a hash'])

      expect(contract.(email: 'jane@doe.org', login: 'jane', address: { street: ' ' }).errors)
        .to eql(address: { street: ['cannot be empty'] })
    end
  end

  context 'with a rule for nested hash and another rule for its member' do
    before do
      contract_class.rule(:address) do
        failure('invalid no matter what')
      end

      contract_class.rule(:address) do
        failure('seriously invalid')
      end

      contract_class.rule(address: :street) do
        failure('cannot be empty') if values[:address][:street].strip.empty?
      end

      contract_class.rule(address: :street) do
        failure('must include a number') unless values[:address][:street].match?(/\d+/)
      end
    end

    it 'applies the rule when nested value passed schema checks' do
      expect(contract.(email: 'jane@doe.org', login: 'jane', address: { street: ' ' }).errors)
        .to eql(
          address: [
            ['invalid no matter what', 'seriously invalid'],
            { street: ['cannot be empty', 'must include a number'] }
          ]
        )
    end
  end

  context 'with a rule that sets a general base error for the whole input' do
    before do
      contract_class.rule do
        failure('this whole thing is invalid')
      end
    end

    it 'sets a base error not attached to any key' do
      expect(contract.(email: 'jane@doe.org', login: '').errors)
        .to eql(login: ['must be filled'])

      expect(contract.(email: 'jane@doe.org', login: '').base_errors)
        .to eql(['this whole thing is invalid'])
    end
  end

  context 'with a list of keys' do
    before do
      contract_class.rule(:email, :login) do
        if !values[:email].empty? && !values[:login].empty?
          failure(:login, 'is not needed when email is provided') 
        end
      end
    end

    it 'applies the rule when all values passed schema checks' do
      expect(contract.(email: nil, login: nil).errors)
        .to eql(email: ['must be a string'], login: ['must be a string'])

      expect(contract.(email: 'jane@doe.org', login: 'jane').errors)
        .to eql(login: ['is not needed when email is provided'])
    end
  end
end
