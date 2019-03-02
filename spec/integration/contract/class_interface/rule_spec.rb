require 'dry/validation/contract'

RSpec.describe Dry::Validation::Contract, '.rule' do
  subject(:contract) { contract_class.new }

  let(:contract_class) do
    Class.new(Dry::Validation::Contract) do
      params do
        required(:email).filled(:string)
        optional(:login).maybe(:string, :filled?)
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
end
