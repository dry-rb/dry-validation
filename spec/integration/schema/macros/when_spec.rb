RSpec.describe 'Macros #when' do
  context 'with a result rule returned from the block' do
    subject(:schema) do
      Dry::Validation.Schema do
        key(:email).maybe

        key(:login).required.when(:true?) do
          value(:email).filled?
        end
      end
    end

    it 'generates check rule' do
      expect(schema.(login: true, email: nil).messages).to eql(
        email: ['must be filled']
      )

      expect(schema.(login: false, email: nil).messages).to be_empty
    end
  end

  describe 'with a result rule depending on another result' do
    subject(:schema) do
      Dry::Validation.Schema do
        key(:left).maybe(:int?)
        key(:right).maybe(:int?)

        key(:compare).maybe(:bool?).when(:true?) do
          value(:left).gt?(value(:right))
        end
      end
    end

    it 'generates check rule' do
      expect(schema.(compare: false, left: nil, right: nil)).to be_success

      expect(schema.(compare: true, left: 1, right: 2).messages).to eql(
        left: ['must be greater than 2']
      )
    end
  end

  describe 'with multiple result rules' do
    subject(:schema) do
      Dry::Validation.Schema do
        key(:email).maybe
        key(:password).maybe

        key(:login).maybe(:bool?).when(:true?) do
          value(:email).filled?
          value(:password).filled?
        end
      end
    end

    it 'generates check rule' do
      expect(schema.(login: false, email: nil, password: nil)).to be_success

      expect(schema.(login: true, email: nil, password: nil).messages).to eql(
        email: ['must be filled'],
        password: ['must be filled']
      )
    end
  end
end
