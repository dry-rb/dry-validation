require 'dry/validation/values'

RSpec.describe Dry::Validation::Values do
  subject(:values) do
    Dry::Validation::Values.new(data)
  end

  let(:data) do
    { name: 'Jane', address: { city: 'Paris' } }
  end

  describe '#dig' do
    it 'returns a value from a nested hash when it exists' do
      expect(values.dig(:address, :city)).to eql('Paris')
    end

    it 'returns nil otherwise' do
      expect(values.dig(:oops, :not_here)).to be(nil)
    end
  end

  describe '#method_missing' do
    it 'forwards to data' do
      result = []

      values.each { |k, v| result << [k, v] }

      expect(result).to eql(values.to_a)
    end

    it 'raises NoMethodError when data does not respond to the meth' do
      expect { values.not_really_implemented }
        .to raise_error(NoMethodError, /not_really_implemented/)
    end
  end
end
