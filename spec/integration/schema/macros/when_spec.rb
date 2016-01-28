RSpec.describe 'Macros #when' do
  subject(:validate) { schema.new }

  context 'with a result rule returned from the block' do
    let(:schema) do
      Class.new(Dry::Validation::Schema) do
        key(:email).maybe

        key(:login).required.when(:true?) do
          value(:email).filled?
        end
      end
    end

    it 'generates check rule' do
      expect(validate.(login: true, email: nil).messages).to eql(
        email: [['email must be filled'], [true, nil]]
      )

      expect(validate.(login: false, email: nil).messages).to be_empty
    end
  end

  describe 'with a result rule depending on another result' do
    let(:schema) do
      Class.new(Dry::Validation::Schema) do
        key(:left).maybe(:int?)
        key(:right).maybe(:int?)

        key(:compare).maybe(:bool?).when(:true?) do
          value(:left).gt?(value(:right))
        end
      end
    end

    it 'generates check rule' do
      expect(validate.(compare: false, left: nil, right: nil)).to be_empty

      expect(validate.(compare: true, left: 1, right: 2).messages).to eql(
        left: [['left must be greater than 2', 'left must be an integer'], [true, 1, 2]]
      )
    end
  end

  describe 'providing custom name' do
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

    it 'generates check rule' do
      expect(validate.(login: true, email: nil).messages).to eql(
        email: [['required when login is true'], [true, nil]]
      )
    end
  end
end
