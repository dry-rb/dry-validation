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

    context 'with a second predicate with args' do
      subject(:schema) do
        Dry::Validation.Schema do
          required(:name).value(:str?, min_size?: 3, max_size?: 6)
        end
      end

      it 'generates str? & min_size? & max_size?' do
        expect(schema.(name: 'fo').messages).to eql(
          name: ['size cannot be less than 3', 'size cannot be greater than 6']
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

    context 'with a schema' do
      subject(:schema) do
        Dry::Validation.Schema do
          required(:data).value(DataSchema)
        end
      end

      before do
        DataSchema = Dry::Validation.Schema do
          required(:foo).filled(size?: 2..10)
        end
      end

      after do
        Object.send(:remove_const, :DataSchema)
      end

      it 'uses the schema' do
        expect(schema.(data: { foo: '' }).messages).to eql(
          data: { foo: ['must be filled', 'length must be within 2 - 10'] }
        )
      end
    end
  end
end
