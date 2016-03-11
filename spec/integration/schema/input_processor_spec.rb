RSpec.describe Dry::Validation::Schema, 'setting input processor in schema' do
  subject(:schema) do
    Dry::Validation.Schema do
      configure do
        config.input_processor = :sanitizer
      end

      key(:email).required

      key(:age).maybe(:int?, gt?: 18)
    end
  end

  it 'rejects unspecified keys' do
    expect(schema.(email: 'jane@doe', age: 19, such: 'key').output).to eql(
      email: 'jane@doe', age: 19
    )
  end
end
