RSpec.describe 'Macros #value' do
  describe 'with no args' do
    it 'raises an exception' do
      expect { Dry::Validation.Schema { required(:email).value } }.to raise_error(
        ArgumentError, "wrong number of arguments (given 0, expected at least 1)"
      )
    end
  end

  describe 'with a type specification' do
    subject(:schema) do
      Dry::Validation.Schema do
        required(:age).value(:int?)
      end
    end

    it 'generates int? rule' do
      expect(schema.(age: nil).messages).to eql(
        age: ['must be an integer']
      )
    end
  end

  describe 'with a predicate with args' do
    context 'with a flat arg' do
      subject(:schema) do
        Dry::Validation.Schema do
          required(:age).value(:int?, gt?: 18)
        end
      end

      it 'generates int? & gt? rule' do
        expect(schema.(age: nil).messages).to eql(
          age: ['must be an integer', 'must be greater than 18']
        )
      end
    end

    context 'with a range arg' do
      subject(:schema) do
        Dry::Validation.Schema do
          required(:age).value(:int?, size?: 18..24)
        end
      end

      it 'generates int? & gt? rule' do
        expect(schema.(age: nil).messages).to eql(
          age: ['must be an integer', 'size must be within 18 - 24']
        )
      end
    end

    context 'with a block' do
      subject(:schema) do
        Dry::Validation.Schema do
          required(:age).value { int? & size?(18..24) }
        end
      end

      it 'generates int? & gt? rule' do
        expect(schema.(age: nil).messages).to eql(
          age: ['must be an integer', 'size must be within 18 - 24']
        )
      end
    end

    context 'with a predicate and a block' do
      subject(:schema) do
        Dry::Validation.Schema do
          required(:age).value(:int?) { size?(18..24) }
        end
      end

      it 'generates int? & gt? rule' do
        expect(schema.(age: nil).messages).to eql(
          age: ['must be an integer', 'size must be within 18 - 24']
        )
      end
    end
  end
end
