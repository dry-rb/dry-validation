# frozen_string_literal: true

RSpec.describe Dry::Validation::Contract, '#message' do
  subject(:contract) do
    Class.new(Dry::Validation::Contract) do
      config.messages_file = SPEC_ROOT.join('fixtures/messages/errors.en.yml').realpath
    end.new
  end

  it 'returns message text' do
    expect(contract.message(:taken, rule: :email, tokens: { email: 'jane@doe.org' }))
      .to eql('looks like jane@doe.org is taken')
  end

  it 'raises error when template was not found' do
    expect { contract.message(:not_here, rule: :email) }
      .to raise_error(Dry::Validation::MissingMessageError, /not_here/)
  end
end
