RSpec.describe 'Macros #confirmation' do
  describe 'with a maybe password with min-size specified' do
    subject(:schema) do
      Dry::Validation.Schema do
        configure do
          def self.messages
            Messages.default.merge(
              en: { errors: { password_confirmation: 'does not match' } }
            )
          end
        end

        key(:password).maybe(min_size?: 3).confirmation
      end
    end

    it 'generates confirmation rule' do
      expect(schema.(password: 'foo', password_confirmation: 'foo')).to be_success

      expect(schema.(password: 'fo', password_confirmation: '').messages).to eql(
        password: ['password size cannot be less than 3']
      )

      expect(schema.(password: 'foo', password_confirmation: 'fo').messages).to eql(
        password_confirmation: ['does not match']
      )
    end
  end
end
