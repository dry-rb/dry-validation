RSpec.describe 'Schema / Macros' do
  subject(:validate) { schema.new }

  describe '#required' do
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

  describe '#required with a type specification' do
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

  describe '#required with a predicate with args' do
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

  describe '#maybe' do
    let(:schema) do
      Class.new(Dry::Validation::Schema) do
        key(:email).maybe
      end
    end

    it 'generates none? | filled? rule' do
      expect(validate.(email: nil).messages).to be_empty
      expect(validate.(email: 'jane@doe').messages).to be_empty
    end
  end

  describe '#maybe with options' do
    let(:schema) do
      Class.new(Dry::Validation::Schema) do
        key(:name).maybe(min_size?: 3)
      end
    end

    it 'generates none? | (filled? & min_size?) rule' do
      expect(validate.(name: nil).messages).to be_empty

      expect(validate.(name: 'jane').messages).to be_empty

      expect(validate.(name: 'xy').messages).to eql(
        name: [['name size cannot be less than 3'], 'xy']
      )
    end
  end

  describe '#confirmation' do
    let(:schema) do
      Class.new(Dry::Validation::Schema) do
        def self.messages
          Messages.default.merge(
            en: { errors: { password_confirmation: 'does not match' } }
          )
        end

        key(:password).maybe(min_size?: 3).confirmation
      end
    end

    it 'generates confirmation rule' do
      expect(validate.(password: 'foo', password_confirmation: 'foo')).to be_empty

      expect(validate.(password: 'fo', password_confirmation: '').messages).to eql(
        password: [['password size cannot be less than 3'], 'fo'],
        password_confirmation: [['password_confirmation must be filled'], '']
      )

      expect(validate.(password: 'foo', password_confirmation: 'fo').messages).to eql(
        password_confirmation: [['does not match'], ['foo', 'fo']]
      )
    end
  end
end
