# frozen_string_literal: true

RSpec.describe Dry::Validation::Evaluator, 'values writer' do
  context 'when key does not exist' do
    subject(:contract) do
      Dry::Validation::Contract.build do
        schema do
          required(:email).filled(:string)
          required(:user_id).filled(:integer)
        end

        rule(:user_id) do
          if values[:user_id].equal?(312)
            values[:user] = 'jane'
          else
            failure(:user, 'must be jane')
          end
        end

        rule(:email) do
          failure('is invalid') if values[:user] == 'jane' && values[:email] != 'jane@doe.org'
        end
      end
    end

    it 'stores new values between rule execution' do
      expect(contract.(user_id: 3, email: 'john@doe.org').errors.to_h).to eql(user: ['must be jane'])
      expect(contract.(user_id: 312, email: 'john@doe.org').errors.to_h).to eql(email: ['is invalid'])
    end
  end

  context 'when key already exists' do
    subject(:contract) do
      Dry::Validation::Contract.build do
        schema do
          required(:email).filled(:string)
        end

        rule(:email) do
          values[:email] = 'foo'
        end
      end
    end

    it 'raises error' do
      expect { contract.(email: 'jane@doe.org') }.to raise_error(ArgumentError, /email/)
    end
  end
end
