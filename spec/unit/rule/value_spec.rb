require 'dry/validation/rule'

RSpec.describe Dry::Validation::Rule::Value do
  include_context 'predicates'

  let(:is_nil) { Dry::Validation::Rule::Value.new(:name, none?) }

  let(:is_string) { Dry::Validation::Rule::Value.new(:name, str?) }

  let(:min_size) { Dry::Validation::Rule::Value.new(:name, min_size?) }

  describe '#call' do
    it 'returns result of a predicate' do
      expect(is_string.(1)).to be_failure
      expect(is_string.('1')).to be_success
    end
  end

  describe '#and' do
    it 'returns a conjunction' do
      string_and_min_size = is_string.and(min_size.curry(3))

      expect(string_and_min_size.('abc')).to be_success
      expect(string_and_min_size.('abcd')).to be_success

      expect(string_and_min_size.(1)).to be_failure
      expect(string_and_min_size.('ab')).to be_failure
    end
  end

  describe '#or' do
    it 'returns a disjunction' do
      nil_or_string = is_nil.or(is_string)

      expect(nil_or_string.(nil)).to be_success
      expect(nil_or_string.('abcd')).to be_success

      expect(nil_or_string.(true)).to be_failure
      expect(nil_or_string.(1)).to be_failure
    end
  end
end
