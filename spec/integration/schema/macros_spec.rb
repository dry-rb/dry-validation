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

  describe '#on' do
    let(:schema) do
      Class.new(Dry::Validation::Schema) do
        key(:login).required.on(:true?) do
          key(:email).required
        end
      end
    end

    it 'generates high-level rule' do
      pending
      expect(validate.(login: true, email: nil).messages).to_not be_empty
    end
  end
end
