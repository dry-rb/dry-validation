RSpec.describe Dry::Validation::Schema::Form, 'defining a schema' do
  subject(:schema) do
    Dry::Validation.Form do
      key(:email).required

      key(:age).maybe(:int?, gt?: 18)

      key(:address).schema do
        key(:city).required
        key(:street).required

        key(:loc) do
          hash? do
            key(:lat).required(:float?)
            key(:lng).required(:float?)
          end
        end
      end

      optional(:password).maybe.confirmation

      optional(:phone_number).maybe(:int?, gt?: 0)

      rule(:email_valid) { value(:email).email? }

      configure do
        def email?(value)
          true
        end
      end
    end
  end

  describe '#messages' do
    it 'returns compiled error messages' do
      result = schema.('email' => '', 'age' => '19')

      expect(result.messages).to eql(
        email: ['must be filled'],
        address: ['is missing']
      )

      expect(result.output).to eql(email: '', age: 19)
    end

    it 'returns hints for nested data' do
      result = schema.(
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
          loc: { lng: ['must be filled'] },
          city: ['must be filled']
        }
      )
    end
  end

  describe '#call' do
    it 'passes when attributes are valid' do
      result = schema.(
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
      result = schema.('email' => '', 'age' => '18')

      expect(result.messages).to eql(
        address: ['is missing'],
        age: ['must be greater than 18'],
        email: ['must be filled']
      )
    end

    it 'handles optionals' do
      result = schema.(
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
