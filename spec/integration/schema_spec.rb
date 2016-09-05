RSpec.describe Dry::Validation::Schema, 'defining key-based schema' do
  describe 'with a flat structure' do
    subject(:schema) do
      Dry::Validation.Schema do
        configure do
          config.input_processor = :form
          config.type_specs = true
        end

        required(:email, :string).filled
        required(:age, [:nil, :int]) { none? | (int? & gt?(18)) }
      end
    end

    it 'passes when input is valid' do
      expect(schema.(email: 'jane@doe', age: 19)).to be_success
      expect(schema.(email: 'jane@doe', age: nil)).to be_success
    end

    it 'fails when input is not valid' do
      expect(schema.(email: 'jane@doe', age: 17)).to_not be_success
    end

    it 'returns result which quacks like hash' do
      input = { email: 'jane@doe', age: 19 }
      result = schema.(input)

      expect(result[:email]).to eql('jane@doe')
      expect(Hash[result]).to eql(input)

      expect(result.to_a).to eql([[:email, 'jane@doe'], [:age, 19]])
    end

    describe '#type_map' do
      it 'returns key=>type map' do
        expect(schema.type_map).to eql(
          email: Types::String, age: Types::Form::Nil | Types::Form::Int
        )
      end

      it 'uses type_map for input processor when it is not empty' do
        expect(schema.(email: 'jane@doe.org', age: '18').to_h).to eql(
          email: 'jane@doe.org', age: 18
        )
      end
    end
  end

  describe 'with nested structures' do
    subject(:schema) do
      class CountrySchema
        def self.schema
          Dry::Validation.Schema do
            required(:name).filled
            required(:code).filled
          end
        end
      end

      Dry::Validation.Schema do
        required(:email).filled

        required(:age).maybe(:int?, gt?: 18)

        required(:address).schema do
          required(:city).filled(min_size?: 3)

          required(:street).filled

          required(:country).schema(CountrySchema)
        end

        required(:phone_numbers).each(:str?)
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
        expect(schema.(input.merge(email: '')).messages).to eql(
          email: ['must be filled']
        )
      end
    end

    describe '#call' do
      it 'passes when attributes are valid' do
        expect(schema.(input)).to be_success
      end

      it 'validates presence of an email and min age value' do
        expect(schema.(input.merge(email: '', age: 18)).messages).to eql(
          email: ['must be filled'], age: ['must be greater than 18']
        )
      end

      it 'validates presence of the email key and type of age value' do
        attrs = {
          name: 'Jane',
          age: '18',
          address: input[:address], phone_numbers: input[:phone_numbers]
        }

        expect(schema.(attrs).messages).to eql(
          email: ['is missing'],
          age: ['must be an integer', 'must be greater than 18']
        )
      end

      it 'validates presence of the address and phone_number keys' do
        attrs = { email: 'jane@doe.org', age: 19 }

        expect(schema.(attrs).messages).to eql(
          address: ['is missing'], phone_numbers: ['is missing']
        )
      end

      it 'validates presence of keys under address and min size of the city value' do
        attrs = input.merge(address: { city: 'NY' })

        expect(schema.(attrs).messages).to eql(
          address: {
            street: ['is missing'],
            country: ['is missing'],
            city: ['size cannot be less than 3']
          }
        )
      end

      it 'validates address type' do
        expect(schema.(input.merge(address: 'totally not a hash')).messages).to eql(
          address: ['must be a hash']
        )
      end

      it 'validates address code and name values' do
        attrs = input.merge(
          address: input[:address].merge(country: { code: 'US', name: '' })
        )

        expect(schema.(attrs).messages).to eql(
          address: { country: { name: ['must be filled'] } }
        )
      end

      it 'validates each phone number' do
        attrs = input.merge(phone_numbers: ['123', 312])

        expect(schema.(attrs).messages).to eql(
          phone_numbers: { 1 => ['must be a string'] }
        )
      end
    end
  end

  context 'nested keys' do
    it 'raises error when defining nested keys without `schema` block`' do
      expect {
        Dry::Validation.Schema { required(:foo).value { required(:bar).value(:str?) } }
      }.to raise_error(ArgumentError, /required/)
    end
  end
end
