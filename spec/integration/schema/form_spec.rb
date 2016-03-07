RSpec.describe Dry::Validation::Schema::Form do
  subject(:validation) { schema.new }

  describe 'defining schema' do
    let(:schema) do
      Class.new(Dry::Validation::Schema::Form) do
        key(:email) { filled? }

        key(:age) { none? | (int? & gt?(18)) }

        key(:address) do
          hash? do
            key(:city, &:filled?)
            key(:street, &:filled?)

            key(:loc) do
              key(:lat) { filled? & float? }
              key(:lng) { filled? & float? }
            end
          end
        end

        optional(:password).maybe.confirmation

        optional(:phone_number) do
          none? | (int? & gt?(0))
        end

        rule(:email_valid) { value(:email).email? }

        def email?(value)
          true
        end
      end
    end

    describe '#messages' do
      it 'returns compiled error messages' do
        result = validation.('email' => '', 'age' => '19')

        expect(result.messages).to eql(
          email: ['email must be filled'],
          address: ['address is missing']
        )

        expect(result.output).to eql(email: '', age: 19)
      end

      it 'returns hints for nested data' do
        result = validation.(
          'email' => 'jane@doe.org',
          'age' => '19',
          'address' => {
            'city' => '',
            'street' => 'Street 1/2',
            'loc' => { 'lat' => '123.456', 'lng' => '' }
          }
        )

        expect(result.messages).to eql(
          address: {
            loc: { lng: ['lng must be filled'] },
            city: ['city must be filled']
          }
        )
      end
    end

    describe '#call' do
      it 'passes when attributes are valid' do
        result = validation.(
          'email' => 'jane@doe.org',
          'age' => '19',
          'address' => {
            'city' => 'NYC',
            'street' => 'Street 1/2',
            'loc' => { 'lat' => '123.456', 'lng' => '456.123' }
          }
        )

        expect(result).to be_success

        expect(result.output).to eql(
          email: 'jane@doe.org', age: 19,
          address: {
            city: 'NYC', street: 'Street 1/2',
            loc: { lat: 123.456, lng: 456.123 }
          }
        )
      end

      it 'validates presence of an email and min age value' do
        expect(validation.('email' => '', 'age' => '18').messages).to eql(
          address: ['address is missing'],
          age: ['age must be greater than 18'],
          email: ['email must be filled']
        )
      end

      it 'handles optionals' do
        result = validation.(
          'email' => 'jane@doe.org',
          'age' => '19',
          'phone_number' => '12',
          'address' => {
            'city' => 'NYC',
            'street' => 'Street 1/2',
            'loc' => { 'lat' => '123.456', 'lng' => '456.123' }
          }
        )

        expect(result).to be_success

        expect(result.output).to eql(
          email: 'jane@doe.org', age: 19, phone_number: 12,
          address: {
            city: 'NYC', street: 'Street 1/2',
            loc: { lat: 123.456, lng: 456.123 }
          }
        )
      end
    end
  end
end
