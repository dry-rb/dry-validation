require 'dry/validation/predicate'
require 'dry/validation/rule'

RSpec.describe Dry::Validation::Rule do
  let(:is_nil) do
    Dry::Validation::Rule::Value.new(
      :name, Dry::Validation::Predicate.new(:nil?) { |input| input.nil? }
    )
  end

  let(:is_string) do
    Dry::Validation::Rule::Value.new(
      :name, Dry::Validation::Predicate.new(:str?) { |input| input.is_a?(String) }
    )
  end

  let(:min_size) do
    Dry::Validation::Rule::Value.new(
      :name, Dry::Validation::Predicate.new(:min_size?) { |size, input| input.size >= size }
    )
  end

  describe Dry::Validation::Rule::Value do
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

  describe Dry::Validation::Rule::Set do
    subject(:address_rule) do
      Dry::Validation::Rule::Set.new([is_string, min_size.curry(6)])
    end

    describe '#call' do
      it 'applies its rules to the input' do
        expect(address_rule.('Address')).to be_success

        expect(address_rule.('Addr')).to be_failure
      end
    end
  end
end
