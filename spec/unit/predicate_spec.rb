require 'dry/validation/predicate'

RSpec.describe Dry::Validation::Predicate do
  describe '#call' do
    it 'returns result of the predicate function' do
      is_empty = Dry::Validation::Predicate.new(:is_empty, &:empty?)

      expect(is_empty.('')).to be(true)

      expect(is_empty.('filled')).to be(false)
    end
  end

  describe '#negation' do
    it 'returns a negated version of a predicate' do
      is_empty = Dry::Validation::Predicate.new(:is_empty, &:empty?)
      is_filled = is_empty.negation

      expect(is_filled.('')).to be(false)
      expect(is_filled.('filled')).to be(true)
    end
  end

  describe '#curry' do
    it 'returns curried predicate' do
      min_age = Dry::Validation::Predicate.new(:min_age) { |age, input| input >= age }

      min_age_18 = min_age.curry(18)

      expect(min_age_18.args).to eql([18])

      expect(min_age_18.(18)).to be(true)
      expect(min_age_18.(19)).to be(true)
      expect(min_age_18.(17)).to be(false)
    end
  end
end
