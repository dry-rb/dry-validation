RSpec.describe 'Macros #required' do
  describe 'with no args' do
    subject(:schema) do
      Dry::Validation.Schema do
        required(:email).not_nil
      end
    end

    it 'generates filled? rule' do
      expect(schema.(email: '').messages).to eql(
        email: ['must be filled']
      )
    end
  end

  describe 'with a type specification' do
    subject(:schema) do
      Dry::Validation.Schema do
        required(:age).not_nil(:int?)
      end
    end

    it 'generates filled? & int? rule' do
      expect(schema.(age: nil).messages).to eql(
        age: ['must be filled']
      )
    end
  end

  describe 'with a predicate with args' do
    context 'with a flat arg' do
      subject(:schema) do
        Dry::Validation.Schema do
          required(:age).not_nil(:int?, gt?: 18)
        end
      end

      it 'generates filled? & int? & gt? rule' do
        expect(schema.(age: nil).messages).to eql(
          age: ['must be filled', 'must be greater than 18']
        )
      end
    end

    context 'with a range arg' do
      subject(:schema) do
        Dry::Validation.Schema do
          required(:age).not_nil(:int?, size?: 18..24)
        end
      end

      it 'generates filled? & int? & gt? rule' do
        expect(schema.(age: nil).messages).to eql(
          age: ['must be filled', 'size must be within 18 - 24']
        )
      end
    end
  end
end
