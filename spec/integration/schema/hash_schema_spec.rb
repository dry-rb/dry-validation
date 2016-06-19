RSpec.describe Dry::Validation::Schema, 'for a hash' do
  context 'without type specs' do
    subject(:schema) do
      Dry::Validation.Schema do
        hash? do
          required(:prefix).filled
          required(:value).filled
        end
      end
    end

    it 'applies its rules to array input' do
      result = schema.(prefix: 1, value: 123)

      expect(result).to be_success

      result = schema.(prefix: 1, value: nil)

      expect(result.messages).to eql(value: ["must be filled"])
    end
  end

  context 'with type specs' do
    subject(:schema) do
      Dry::Validation.Form do
        configure { config.type_specs = true }

        hash? do
          required(:prefix, :int).filled
          required(:value, :int).filled
        end
      end
    end

    it 'applies its rules to coerced array input' do
      result = schema.(prefix: 1, value: '123')

      expect(result).to be_success

      expect(result.output).to eql(prefix: 1, value: 123)

      result = schema.(prefix: 1, value: nil)

      expect(result.messages).to eql(value: ["must be filled"])
    end
  end
end
