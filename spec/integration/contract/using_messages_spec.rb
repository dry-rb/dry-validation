require 'dry/validation/contract'

RSpec.describe Dry::Validation::Contract do
  subject(:contract) do
    Class.new(Dry::Validation::Contract) do
      config.messages_file = SPEC_ROOT.join('fixtures/messages/errors.en.yml').realpath

      params do
        required(:email).filled(:string)
      end

      rule(:email) do
        value = params[:email]
        failure(:invalid) unless value.include?('@')
        failure(:taken, email: value) if value == 'jane@doe.org'
      end
    end.new
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
