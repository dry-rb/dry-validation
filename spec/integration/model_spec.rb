RSpec.describe Dry::Validation::Schema, 'defining attr-based schema' do
  describe 'with a flat structure' do
    subject(:schema) do
      Dry::Validation.Schema do
        attr(:email).required
        attr(:age) { none? | (int? & gt?(18)) }
      end
    end

    let(:model) { Class.new(OpenStruct) }

    it 'passes when input is valid' do
      expect(schema.(model.new(email: 'jane@doe', age: 19))).to be_success
      expect(schema.(model.new(email: 'jane@doe', age: nil))).to be_success
    end

    it 'fails when input is not valid' do
      expect(schema.(model.new(email: 'jane@doe', age: 17))).to_not be_success
    end
  end

  describe 'with nested structures' do
    subject(:schema) do
      Dry::Validation.Schema do
        attr(:email).required

        attr(:age) { none? | (int? & gt?(18)) }

        attr(:address) do
          attr(:city) { min_size?(3) }

          attr(:street).required

          attr(:country) do
            attr(:name).required
            attr(:code).required
          end
        end

        attr(:phone_numbers) do
          array? { each(&:str?) }
        end
      end
    end

    let(:input) do
      OpenStruct.new(
        email: 'jane@doe.org',
        age: 19,
        address: OpenStruct.new(
          city: 'NYC', street: 'Street 1/2', country: OpenStruct.new(code: 'US', name: 'USA')
        ),
        phone_numbers: [
          '123456', '234567'
        ]
      )
    end

    describe '#messages' do
      it 'returns compiled error messages' do
        input.email = ''

        expect(schema.(input).messages).to eql(
          email: ['email must be filled']
        )
      end
    end

    describe '#call' do
      it 'passes when attributes are valid' do
        expect(schema.(input)).to be_success
      end

      it 'validates presence of an email and min age value' do
        input.email = ''
        input.age = 18

        expect(schema.(input).messages).to eql(
          email: ['email must be filled'], age: ['age must be greater than 18']
        )
      end

      it 'validates type of age value' do
        input.age = '18'

        expect(schema.(input).messages).to eql(
          age: ['age must be an integer', 'age must be greater than 18']
        )
      end

      it 'validates presence of phone_number keys' do
        input.phone_numbers = nil

        expect(schema.(input).messages).to eql(
          phone_numbers: ['phone_numbers must be an array']
        )
      end

      it 'validates presence of address street & county & min size of the city' do
        input.address.city = 'NY'
        input.address.street = nil
        input.address.country.name = nil

        expect(schema.(input).messages).to eql(
          address: {
            street: ['street must be filled'],
            country: { name: ['name must be filled'] },
            city: ['city size cannot be less than 3']
          }
        )
      end

      it 'validates each phone number' do
        input.phone_numbers = ['123', 312]

        expect(schema.(input).messages).to eql(
          phone_numbers: { 1 => ['1 must be a string'] }
        )
      end
    end
  end
end
