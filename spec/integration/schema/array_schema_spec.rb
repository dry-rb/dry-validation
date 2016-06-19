RSpec.describe Dry::Validation::Schema, 'for an array' do
  context 'without type specs' do
    subject(:schema) do
      Dry::Validation.Schema do
        each do
          schema do
            required(:prefix).filled
            required(:value).filled
          end
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

  context 'with type specs' do
    subject(:schema) do
      Dry::Validation.Form do
        configure { config.type_specs = true }

        each do
          schema do
            required(:prefix, :int).filled
            required(:value, :int).filled
          end
        end
      end
    end

    it 'applies its rules to coerced array input' do
      result = schema.([{ prefix: 1, value: '123' }, { prefix: 2, value: 456 }])

      expect(result).to be_success

      expect(result.output).to eql(
        [{ prefix: 1, value: 123 }, { prefix: 2, value: 456 }]
      )

      result = schema.([{ prefix: 1, value: nil }, { prefix: nil, value: 456 }])

      expect(result.messages).to eql(
        0 => { value: ["must be filled"] },
        1 => { prefix: ["must be filled"] }
      )
    end
  end
end
