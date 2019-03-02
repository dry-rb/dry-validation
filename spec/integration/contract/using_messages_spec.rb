require 'dry/validation/contract'

RSpec.describe Dry::Validation::Contract do
  shared_context 'translated messages' do
    subject(:contract) do
      contract_class.new
    end

    let(:contract_class) do
      Class.new(Dry::Validation::Contract) do
        config.messages_file = SPEC_ROOT.join('fixtures/messages/errors.en.yml').realpath

        params do
          required(:email).filled(:string)
        end

        rule(:email) do
          value = values[:email]
          failure(:invalid) unless value.include?('@')
          failure(:taken, email: value) if value == 'jane@doe.org'
        end
      end
    end

    it 'configures messages for the schema' do
      expect(contract.schema.config.messages_file).to eql(contract.class.config.messages_file)
    end

    describe 'failure' do
      it 'uses messages for failures' do
        expect(contract.(email: 'foo').errors)
          .to eql(email: ['oh noez bad email'])
      end

      it 'passes tokens to message templates' do
        expect(contract.(email: 'jane@doe.org').errors)
          .to eql(email: ['looks like jane@doe.org is taken'])
      end
    end
  end

  context 'using :yaml messages' do
    before { contract_class.config.messages = :yaml }

    include_context 'translated messages'
  end

  context 'using :i18n messages' do
    before { contract_class.config.messages = :i18n }

    include_context 'translated messages'
  end
end
