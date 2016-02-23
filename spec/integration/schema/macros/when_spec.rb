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
        email: ['email must be filled']
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
      expect(validate.(compare: false, left: nil, right: nil)).to be_success

      expect(validate.(compare: true, left: 1, right: 2).messages).to eql(
        left: ['left must be greater than 2']
      )
    end
  end

  describe 'with multiple result rules' do
    let(:schema) do
      Class.new(Dry::Validation::Schema) do
        key(:email).maybe
        key(:password).maybe

        key(:login).maybe(:bool?).when(:true?) do
          value(:email).filled?
          value(:password).filled?
        end
      end
    end

    it 'generates check rule' do
      expect(validate.(login: false, email: nil, password: nil)).to be_success

      expect(validate.(login: true, email: nil, password: nil).messages).to eql(
        email: ['email must be filled'],
        password: ['password must be filled']
      )
    end
  end
end
