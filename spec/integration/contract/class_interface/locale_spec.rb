# frozen_string_literal: true

require 'dry/validation/contract'

RSpec.describe Dry::Validation::Contract, 'setting default locale' do
  subject(:contract) do
    Dry::Validation.Contract do
      config.locale = :pl
      config.messages.backend = :i18n
      config.messages.load_paths << SPEC_ROOT.join('fixtures/messages/errors.pl.yml')

      params do
        required(:email).filled(:string)
      end

      rule(:email) do
        key.failure(:invalid) unless values[:email].include?('@')
      end
    end
  end

  it 'uses configured default locale' do
    expect(contract.(email: 'foo').errors.to_h).to eql(email: ['oh nie zły email'])
  end
end
