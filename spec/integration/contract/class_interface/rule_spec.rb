require 'dry/validation/contract'

RSpec.describe Dry::Validation::Contract, '.rule' do
  subject(:contract) { contract_class.new }

  let(:contract_class) do
    Class.new(Dry::Validation::Contract) do
      params do
        required(:email).filled(:string)
        optional(:login).filled(:string)
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

  context 'with a list of keys' do
    before do
      contract_class.rule(:email, :login) do
        failure(:login, 'is not needed when email is provided') if email.size > 0 && login.size > 0
      end
    end

    it 'applies the rule when all values passed schema checks' do
      expect(contract.(email: nil, login: nil).errors)
        .to eql(email: ['must be a string'], login: ['must be a string'])
    end
  end
end
