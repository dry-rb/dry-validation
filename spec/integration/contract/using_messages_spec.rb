# frozen_string_literal: true

require 'dry/validation/contract'

RSpec.describe Dry::Validation::Contract do
  shared_context 'translated messages' do
    subject(:contract) do
      contract_class.new
    end

    let(:contract_class) do
      Class.new(Dry::Validation::Contract) do
        config.messages.load_paths << SPEC_ROOT.join('fixtures/messages/errors.en.yml').realpath

        params do
          required(:email).filled(:string, min_size?: 3, max_size?: 100)
        end

        rule(:email) do
          value = values[:email]
          key.failure(:invalid) unless value.include?('@')
          key.failure(:taken, values.to_h) if value == 'jane@doe.org'
        end
      end
    end

    it 'configures messages for the schema' do
      expect(contract.schema.config.messages.load_paths)
        .to eql(contract.class.config.messages.load_paths)
    end

    describe 'result errors' do
      it 'supports full: true option for schema errors' do
        expect(contract.(email: '').errors(full: true).map(&:to_s))
          .to eql([
            'E-mail must be filled',
            'E-mail size cannot be less than 3',
            'E-mail size cannot be greater than 100'
          ])
      end

      it 'supports full: true option for contract errors' do
        expect(contract.(email: 'jane').errors(full: true).map(&:to_s))
          .to eql(['E-mail oh noez bad email'])
      end
    end

    describe 'failure' do
      it 'uses messages for failures' do
        expect(contract.(email: 'foo').errors.to_h)
          .to eql(email: ['oh noez bad email'])
      end

      it 'passes tokens to message templates' do
        expect(contract.(email: 'jane@doe.org').errors.to_h)
          .to eql(email: ['looks like jane@doe.org is taken'])
      end
    end
  end

  context 'using :yaml messages' do
    before do contract_class.config.messages.backend = :yaml end

    include_context 'translated messages'
  end

  context 'using :i18n messages' do
    before do contract_class.config.messages.backend = :i18n end

    include_context 'translated messages'
  end
end
