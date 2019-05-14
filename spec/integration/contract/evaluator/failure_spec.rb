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
    context 'with a string message' do
      before do
        contract_class.rule(:email) do
          key(:contact).failure('is invalid')
        end
      end

      it 'sets error under specified key' do
        expect(contract.(email: 'foo').errors.to_h).to eql(contact: ['is invalid'])
      end
    end

    context 'with a nested key as a hash and a string message' do
      before do
        contract_class.rule(:email) do
          key(contact: :details).failure('is invalid')
        end
      end

      it 'sets error under specified key' do
        expect(contract.(email: 'foo').errors.to_h).to eql(contact: { details: ['is invalid'] })
      end
    end

    context 'with a symbol' do
      before do
        contract_class.config.messages.load_paths << SPEC_ROOT
          .join('fixtures/messages/errors.en.yml').realpath

        contract_class.rule(:email) do
          key(:contact).failure(:wrong)
        end
      end

      it 'sets error under specified key' do
        expect(contract.(email: 'foo').errors.to_h).to eql(contact: ['not right'])
      end
    end
  end

  context 'setting base failures' do
    context 'string failure' do
      before do
        contract_class.rule(:email) do
          base.failure('is invalid')
        end
      end

      it 'sets error under specified key' do
        expect(contract.(email: 'foo').errors.to_h).to eql(nil => ['is invalid'])
      end
    end

    context 'symbol failure' do
      before do
        contract_class.rule(:email) do
          base.failure(:not_good_enough)
        end
      end

      it 'sets error under specified key' do
        expect(contract.(email: 'foo').errors.to_h).to eql(nil => ['Email should be nicer'])
      end
    end
  end

  context 'setting failures with meta data' do
    before do
      contract_class.rule(:email) do
        key.failure(text: 'is invalid', code: 102)
      end
    end

    it 'sets error under specified key' do
      errors = contract.(email: 'foo').errors

      expect(errors.to_h).to eql(email: [text: 'is invalid', code: 102])
      expect(errors.first.meta).to eql(code: 102)
    end
  end

  context 'when localized message id is invalid' do
    before do
      contract_class.rule(:email) do
        key.failure([:oops_bad_id])
      end
    end

    it 'raises a meaningful error' do
      expect { contract.(email: 'foo') }.to raise_error(ArgumentError, /oops_bad_id/)
    end
  end
end
