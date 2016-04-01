RSpec.describe 'Macros #confirmation' do
  describe 'with a maybe password with min-size specified' do
    subject(:schema) do
      Dry::Validation.Schema do
        configure do
          config.input_processor = :sanitizer

          def self.messages
            Messages.default.merge(
              en: { errors: { password_confirmation: 'does not match' } }
            )
          end
        end

        required(:password).maybe(min_size?: 3).confirmation
      end
    end

    it 'passes when values are equal' do
      expect(schema.(password: 'foo', password_confirmation: 'foo')).to be_success
    end

    it 'fails when source value is invalid' do
      expect(schema.(password: 'fo', password_confirmation: nil).messages).to eql(
        password: ['size cannot be less than 3']
      )
    end

    it 'fails when values are not equal' do
      expect(schema.(password: 'foo', password_confirmation: 'fo').messages).to eql(
        password_confirmation: ['does not match']
      )
    end
  end
end
