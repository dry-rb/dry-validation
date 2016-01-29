RSpec.describe 'Macros #confirmation' do
  subject(:validate) { schema.new }

  describe 'with a maybe password with min-size specified' do
    let(:schema) do
      Class.new(Dry::Validation::Schema) do
        def self.messages
          Messages.default.merge(
            en: { errors: { password_confirmation: 'does not match' } }
          )
        end

        key(:password).maybe(min_size?: 3).confirmation
      end
    end

    it 'generates confirmation rule' do
      pending

      expect(validate.(password: 'foo', password_confirmation: 'foo')).to be_success

      expect(validate.(password: 'fo', password_confirmation: '').messages).to eql(
        password: [['password size cannot be less than 3'], 'fo'],
        password_confirmation: [['password_confirmation must be filled'], '']
      )

      expect(validate.(password: 'foo', password_confirmation: 'fo').messages).to eql(
        password_confirmation: [['does not match'], ['foo', 'fo']]
      )
    end
  end
end
