RSpec.describe Dry::Validation::Schema do
  subject(:validation) { schema.new }

  describe 'defining schema with optional keys' do
    let(:schema) do
      Class.new(Dry::Validation::Schema) do
        optional(:email) { |email| email.filled? }

        key(:address) do |address|
          address.key(:city, &:filled?)
          address.key(:street, &:filled?)

          address.optional(:phone_number) do |phone_number|
            phone_number.none? | phone_number.str?
          end
        end
      end
    end

    describe '#call' do
      it 'skips rules when key is not present' do
        expect(validation.(address: { city: 'NYC', street: 'Street 1/2' })).to be_empty
      end

      it 'applies rules when key is present' do
        expect(validation.(email: '')).to_not be_empty
      end
    end
  end
end
