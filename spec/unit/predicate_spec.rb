require 'dry/validation/predicate'

RSpec.describe Dry::Validation::Predicate do
  describe '#call' do
    it 'returns result of the predicate function' do
      is_empty = Dry::Validation::Predicate.new(:is_empty) { |str| str.empty? }

      expect(is_empty.('')).to be(true)

      expect(is_empty.('filled')).to be(false)
    end
  end

  describe '#negation' do
    it 'returns a negated version of a predicate' do
      is_empty = Dry::Validation::Predicate.new(:is_empty) { |str| str.empty? }
      is_filled = is_empty.negation

      expect(is_filled.('')).to be(false)
      expect(is_filled.('filled')).to be(true)
    end
  end
end
