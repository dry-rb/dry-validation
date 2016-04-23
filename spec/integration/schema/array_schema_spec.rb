RSpec.describe Dry::Validation::Schema, 'for an array' do
  subject(:schema) do
    Dry::Validation.Schema do
      each do
        required(:prefix).filled
        required(:value).filled
      end
    end
  end

  it 'applies its rules to array input' do
    result = schema.([{ prefix: 1, value: 123 }, { prefix: 2, value: 456 }])

    expect(result).to be_success

    result = schema.([{ prefix: 1, value: nil }, { prefix: nil, value: 456 }])

    expect(result.messages).to eql(
      0 => { value: ["must be filled"] },
      1 => { prefix: ["must be filled"] }
    )
  end
end
