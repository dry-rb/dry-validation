require 'dry/validation/predicate'
require 'dry/validation/rule'

RSpec.describe Dry::Validation::Rule do
  describe Dry::Validation::Rule::Value do
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
  end

  describe Dry::Validation::Rule::Key do
    subject(:presence_rule) { Dry::Validation::Rule::Key.new(:name, key_exist) }

    let(:string_rule) { Dry::Validation::Rule::Value.new(:name, is_string) }

    let(:key_exist) do
      Dry::Validation::Predicate.new do |key, input|
        input.key?(key)
      end
    end

    let(:is_string) do
      Dry::Validation::Predicate.new do |input|
        input.is_a?(String)
      end
    end

    describe '#call' do
      it 'applies predicate to the value' do
        expect(presence_rule.(name: 'Jane')).to be_success
        expect(presence_rule.({})).to be_failure
      end
    end

    describe '#and' do
      it 'returns conjunction rule where value is passed to the right' do
        present_and_string = presence_rule.and(string_rule)

        expect(present_and_string.(name: 'Jane')).to be_success

        expect(present_and_string.({})).to be_failure
        expect(present_and_string.(name: 1)).to be_failure
      end
    end
  end
end
