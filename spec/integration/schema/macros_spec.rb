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

  describe '#when' do
    let(:schema) do
      Class.new(Dry::Validation::Schema) do
        key(:email).maybe

        key(:login).required.when(:true?) do
          value(:email).filled?
        end
      end
    end

    it 'generates high-level rule' do
      expect(validate.(login: true, email: nil).messages).to eql(
        email: [['email must be filled'], [true, nil]]
      )

      expect(validate.(login: false, email: nil).messages).to be_empty
    end
  end

  describe '#when with a group rule' do
    let(:schema) do
      Class.new(Dry::Validation::Schema) do
        key(:left).maybe(:int?)
        key(:right).maybe(:int?)

        key(:compare).maybe(:bool?).when(:true?) do
          value(:left).gt?(value(:right))
        end
      end
    end

    it 'generates high-level rule dependant on another high-level rule' do
      expect(validate.(compare: false, left: nil, right: nil)).to be_empty

      expect(validate.(compare: true, left: 1, right: 2).messages).to eql(
        left: [['left must be greater than 2', 'left must be an integer'], [true, 1, 2]]
      )
    end
  end

  describe '#when with a custom name' do
    let(:schema) do
      Class.new(Dry::Validation::Schema) do
        def self.messages
          Messages.default.merge(
            en: { errors: { email: { required: 'required when login is true' } } }
          )
        end

        key(:email).maybe

        key(:login).required.when(:true?, email: :required) do
          value(:email).filled?
        end
      end
    end

    it 'generates high-level rule' do
      expect(validate.(login: true, email: nil).messages).to eql(
        email: [['required when login is true'], [true, nil]]
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
