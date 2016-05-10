RSpec.describe Dry::Validation::Schema do
  describe 'defining schema with optional keys' do
    subject(:schema) do
      Dry::Validation.Schema do
        optional(:email) { |email| email.filled? }

        required(:address).schema do
          required(:city, &:filled?)
          required(:street, &:filled?)

          optional(:phone_number) do
            none? | str?
          end
        end
      end
    end

    describe '#call' do
      it 'skips rules when key is not present' do
        expect(schema.(address: { city: 'NYC', street: 'Street 1/2' })).to be_success
      end

      it 'applies rules when key is present' do
        expect(schema.(email: '')).to_not be_success
      end
    end
  end
end
