RSpec.describe Dry::Validation do
  before do
    module Test
      class Validation < Dry::Validation::Schema
        key(:name).present?

        key(:age).present? do |value|
          value.int?
        end
      end
    end
  end

  describe 'defining schema' do
    it 'works' do
      validation = Test::Validation.new

      expect(validation.(name: 'Jane', age: 18)).to be_empty

      expect(validation.(name: '', age: 18)).to eql(name: [validation.rules[:name]])
      expect(validation.(name: 'Jane', age: '18')).to eql(age: [validation.rules[:age]])
    end
  end
end
