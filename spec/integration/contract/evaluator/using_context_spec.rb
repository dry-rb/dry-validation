# frozen_string_literal: true

RSpec.describe Dry::Validation::Evaluator, 'using context' do
  before(:all) do
    Dry::Validation.load_extensions(:hints)
  end

  context 'when key does not exist' do
    subject(:contract) do
      Dry::Validation::Contract.build do
        schema do
          required(:email).filled(:string)
          required(:user_id).filled(:integer)
        end

        rule(:user_id) do |ctx|
          if values[:user_id].equal?(312)
            ctx[:user] = 'jane'
          else
            key(:user).failure('must be jane')
          end
        end

        rule(:email) do |ctx|
          key.failure('is invalid') if ctx[:user] == 'jane' && values[:email] != 'jane@doe.org'
        end
      end
    end

    it 'stores new values between rule execution' do
      expect(contract.(user_id: 3, email: 'john@doe.org').errors.to_h).to eql(user: ['must be jane'])
      expect(contract.(user_id: 312, email: 'john@doe.org').errors.to_h).to eql(email: ['is invalid'])
    end

    it 'exposes context in result' do
      expect(contract.(user_id: 312, email: 'jane@doe.org').context[:user]).to eql('jane')
    end
  end
end
