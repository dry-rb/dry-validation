# frozen_string_literal: true

RSpec.describe Dry::Validation::Evaluator do
  subject(:contract) do
    contract_class.new
  end

  let(:contract_class) do
    Class.new(Dry::Validation::Contract) do
      schema do
        required(:email).filled(:string)
      end
    end
  end

  context 'setting key failures using default rule path' do
    before do
      contract_class.rule(:email) do
        key.failure('is invalid')
      end
    end

    it 'sets error under specified key' do
      expect(contract.(email: 'foo').errors.to_h).to eql(email: ['is invalid'])
    end
  end

  context 'setting key failures using via explicit path' do
    before do
      contract_class.rule(:email) do
        key(:contact).failure('is invalid')
      end
    end

    it 'sets error under specified key' do
      expect(contract.(email: 'foo').errors.to_h).to eql(contact: ['is invalid'])
    end
  end

  context 'setting base failures' do
    before do
      contract_class.rule(:email) do
        base.failure('is invalid')
      end
    end

    it 'sets error under specified key' do
      expect(contract.(email: 'foo').errors.to_h).to eql(nil => ['is invalid'])
    end
  end
end
