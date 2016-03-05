RSpec.describe Dry::Validation::Schema, 'defining key-based schema' do
  subject(:validate) { schema.new }

  describe 'with a flat structure' do
    let(:schema) do
      Class.new(Dry::Validation::Schema) do
        key(:email).required
        key(:age) { none? | (int? & gt?(18)) }
      end
    end

    it 'passes when input is valid' do
      expect(validate.(email: 'jane@doe', age: 19)).to be_success
      expect(validate.(email: 'jane@doe', age: nil)).to be_success
    end

    it 'fails when input is not valid' do
      expect(validate.(email: 'jane@doe', age: 17)).to_not be_success
    end
  end

  describe 'with nested structures' do
    let(:schema) do
      Class.new(Dry::Validation::Schema) do
        key(:email).required

        key(:age) { none? | (int? & gt?(18)) }

        key(:address) do
          hash? do
            key(:city) { min_size?(3) }

            key(:street).required

            key(:country) do
              key(:name).required
              key(:code).required
            end
          end
        end

        key(:phone_numbers) do
          array? { each(&:str?) }
        end
      end
    end

    let(:input) do
      {
        email: 'jane@doe.org',
        age: 19,
        address: { city: 'NYC', street: 'Street 1/2', country: { code: 'US', name: 'USA' } },
        phone_numbers: [
          '123456', '234567'
        ]
      }.freeze
    end

    describe '#messages' do
      it 'returns compiled error messages' do
        expect(validate.(input.merge(email: '')).messages).to eql(
          email: ['email must be filled']
        )
      end
    end

    describe '#call' do
      it 'passes when attributes are valid' do
        expect(validate.(input)).to be_success
      end

      it 'validates presence of an email and min age value' do
        expect(validate.(input.merge(email: '', age: 18)).messages).to eql(
          email: ['email must be filled'], age: ['age must be greater than 18']
        )
      end

      it 'validates presence of the email key and type of age value' do
        attrs = {
          name: 'Jane',
          age: '18',
          address: input[:address], phone_numbers: input[:phone_numbers]
        }

        expect(validate.(attrs).messages).to eql(
          email: ['email is missing'],
          age: ['age must be an integer', 'age must be greater than 18']
        )
      end

      it 'validates presence of the address and phone_number keys' do
        attrs = { email: 'jane@doe.org', age: 19 }

        expect(validate.(attrs).messages).to eql(
          address: ['address is missing'],
          phone_numbers: ['phone_numbers is missing']
        )
      end

      it 'validates presence of keys under address and min size of the city value' do
        attrs = input.merge(address: { city: 'NY' })

        expect(validate.(attrs).messages).to eql(
          address: {
            street: ['street is missing'],
            country: ['country is missing'],
            city: ['city size cannot be less than 3']
          }
        )
      end

      it 'validates address type' do
        expect(validate.(input.merge(address: 'totally not a hash')).messages).to eql(
          address: ['address must be a hash']
        )
      end

      it 'validates address code and name values' do
        attrs = input.merge(
          address: input[:address].merge(country: { code: 'US', name: '' })
        )

        expect(validate.(attrs).messages).to eql(
          address: { country: { name: ['name must be filled'] } }
        )
      end

      it 'validates each phone number' do
        attrs = input.merge(phone_numbers: ['123', 312])

        expect(validate.(attrs).messages).to eql(
          phone_numbers: { 1 => ['1 must be a string'] }
        )
      end
    end
  end
end
