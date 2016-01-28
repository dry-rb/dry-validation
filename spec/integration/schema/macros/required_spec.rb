RSpec.describe 'Macros #required' do
  subject(:validate) { schema.new }

  describe 'with no args' do
    let(:schema) do
      Class.new(Dry::Validation::Schema) do
        key(:email).required
      end
    end

    it 'generates filled? rule' do
      expect(validate.(email: '').messages).to eql(
        email: [['email must be filled'], '']
      )
    end
  end

  describe 'with a type specification' do
    let(:schema) do
      Class.new(Dry::Validation::Schema) do
        key(:age).required(:int?)
      end
    end

    it 'generates filled? & int? rule' do
      expect(validate.(age: nil).messages).to eql(
        age: [['age must be filled', 'age must be an integer'], nil]
      )
    end
  end

  describe 'with a predicate with args' do
    let(:schema) do
      Class.new(Dry::Validation::Schema) do
        key(:age).required(:int?, gt?: 18)
      end
    end

    it 'generates filled? & int? & gt? rule' do
      expect(validate.(age: nil).messages).to eql(
        age: [
          ['age must be filled',
           'age must be an integer',
           'age must be greater than 18'], nil]
      )
    end
  end
end
