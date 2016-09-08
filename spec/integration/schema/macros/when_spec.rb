RSpec.describe 'Macros #when' do
  context 'with a result rule returned from the block' do
    subject(:schema) do
      Dry::Validation.Schema do
        required(:email).maybe

        required(:login).filled.when(:true?) do
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
        required(:left).maybe(:int?)
        required(:right).maybe(:int?)

        required(:compare).maybe(:bool?).when(:true?) do
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

  context 'predicate with options' do
    subject(:schema) do
      Dry::Validation.Schema do
        required(:bar).maybe

        required(:foo).filled.when(size?: 3) do
          value(:bar).filled?
        end
      end
    end

    it 'generates check rule' do
      expect(schema.(foo: [1,2,3], bar: nil).messages).to eql(
        bar: ['must be filled']
      )

      expect(schema.(foo: [1,2], bar: nil).messages).to be_empty
    end
  end
end
