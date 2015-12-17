RSpec.describe 'Validation hints' do
  subject(:validation) { schema.new }

  let(:schema) do
    Class.new(Dry::Validation::Schema) do
      key(:age) do |age|
        age.none? | (age.int? & age.gt?(18))
      end
    end
  end

  describe '#messages' do
    it 'provides hints for additional rules that were not checked' do
      expect(validation.(age: '17').messages).to eql(
        age: [['age must be an integer', 'age must be greater than 18'], '17']
      )
    end
  end
end
