RSpec.describe 'Macros #maybe' do
  describe 'with no args' do
    subject(:schema) do
      Dry::Validation.Schema do
        required(:email).maybe
      end
    end

    it 'generates none? | filled? rule' do
      expect(schema.(email: nil).messages).to be_empty
      expect(schema.(email: 'jane@doe').messages).to be_empty
    end
  end

  describe 'with a predicate with args' do
    subject(:schema) do
      Dry::Validation.Schema do
        required(:name).maybe(min_size?: 3)
      end
    end

    it 'generates none? | (filled? & min_size?) rule' do
      expect(schema.(name: nil).messages).to be_empty

      expect(schema.(name: 'jane').messages).to be_empty

      expect(schema.(name: 'xy').messages).to eql(
        name: ['size cannot be less than 3']
      )
    end
  end

  describe 'with a block' do
    subject(:schema) do
      Dry::Validation.Schema do
        required(:name).maybe { str? & min_size?(3) }
      end
    end

    it 'generates none? | (str? & min_size?) rule' do
      expect(schema.(name: nil).messages).to be_empty

      expect(schema.(name: 'jane').messages).to be_empty

      expect(schema.(name: 'xy').messages).to eql(
        name: ['size cannot be less than 3']
      )
    end
  end

  describe 'with a predicate and a block' do
    subject(:schema) do
      Dry::Validation.Schema do
        required(:name).maybe(:str?) { min_size?(3) }
      end
    end

    it 'generates none? | (str? & min_size?) rule' do
      expect(schema.(name: nil).messages).to be_empty

      expect(schema.(name: 'jane').messages).to be_empty

      expect(schema.(name: 'xy').messages).to eql(
        name: ['size cannot be less than 3']
      )
    end
  end
end

