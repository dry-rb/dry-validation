RSpec.describe Dry::Validation::Schema::Form, 'explicit types' do
  context 'single type spec without rules' do
    subject(:schema) do
      Dry::Validation.Form do
        required(:age, :int)
      end
    end

    it 'uses form coercion' do
      expect(schema.('age' => '19').to_h).to eql(age: 19)
    end
  end

  context 'single type spec with rules' do
    subject(:schema) do
      Dry::Validation.Form do
        required(:age, :int).value(:int?, gt?: 18)
      end
    end

    it 'applies rules to coerced value' do
      expect(schema.(age: 19).messages).to be_empty
      expect(schema.(age: 18).messages).to eql(age: ['must be greater than 18'])
    end
  end

  context 'sum type spec without rules' do
    subject(:schema) do
      Dry::Validation.Form do
        required(:age, [:nil, :int])
      end
    end

    it 'uses form coercion' do
      expect(schema.('age' => '19').to_h).to eql(age: 19)
      expect(schema.('age' => '').to_h).to eql(age: nil)
    end
  end

  context 'sum type spec with rules' do
    subject(:schema) do
      Dry::Validation.Form do
        required(:age, [:nil, :int]).maybe(:int?, gt?: 18)
      end
    end

    it 'applies rules to coerced value' do
      expect(schema.(age: nil).messages).to be_empty
      expect(schema.(age: 19).messages).to be_empty
      expect(schema.(age: 18).messages).to eql(age: ['must be greater than 18'])
    end
  end

  context 'using a type object' do
    subject(:schema) do
      Dry::Validation.Form do
        required(:age, Types::Form::Nil | Types::Form::Int)
      end
    end

    it 'uses form coercion' do
      expect(schema.('age' => '').to_h).to eql(age: nil)
      expect(schema.('age' => '19').to_h).to eql(age: 19)
    end
  end
end
