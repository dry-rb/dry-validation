RSpec.describe 'Macros #maybe' do
  subject(:validate) { schema.new }

  describe 'with no args' do
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

  describe 'with a predicate with args' do
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
end
