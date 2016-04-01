RSpec.describe Dry::Validation::Schema, 'setting input processor in schema' do
  subject(:schema) do
    Dry::Validation.Schema do
      configure do
        config.input_processor = :sanitizer
      end

      required(:email).not_nil

      required(:age).maybe(:int?, gt?: 18)

      required(:address).schema do
        required(:city).not_nil
        required(:street).not_nil
      end

      required(:phone_numbers).each do
        required(:prefix).not_nil
        required(:value).not_nil
      end
    end
  end

  it 'rejects unspecified keys' do
    result = schema.(
      email: 'jane@doe',
      age: 19,
      such: 'key',
      address: { city: 'NYC', street: 'Street', wow: 'bad' },
      phone_numbers: [
        { prefix: '48', value: '123' },
        { lol: '!!', prefix: '1', value: '312' }
      ]
    )

    expect(result.output).to eql(
      email: 'jane@doe',
      age: 19,
      address: { city: 'NYC', street: 'Street' },
      phone_numbers: [
        { prefix: '48', value: '123' },
        { prefix: '1', value: '312' }
      ]
    )
  end
end
