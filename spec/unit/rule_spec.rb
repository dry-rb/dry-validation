require 'dry/validation/predicate'
require 'dry/validation/rule'

RSpec.describe Dry::Validation::Rule do
  describe '#call' do
    it 'returns result of a predicate' do
      is_string = -> input { input.is_a?(String) }

      rule = Dry::Validation::Rule.new(:name, is_string)

      expect(rule.(1)).to be_failure
      expect(rule.('1')).to be_success
    end
  end

  describe '#compose' do
    it 'returns pipelined rule' do
      is_string = Dry::Validation::Rule.new(
        :name, Dry::Validation::Predicate.new { |input| input.is_a?(String) }
      )

      min_size = Dry::Validation::Rule.new(
        :name, Dry::Validation::Predicate.new { |size, input| input.size >= size }
      )

      string_min_size = is_string.compose(min_size.curry(3))

      expect(string_min_size.('abc')).to be_success
      expect(string_min_size.('abcd')).to be_success

      expect(string_min_size.(1)).to be_failure
      expect(string_min_size.('ab')).to be_failure
    end
  end

  describe Dry::Validation::Rule::Key do
    subject(:presence_rule) { Dry::Validation::Rule::Key.new(:name, key_exist) }

    let(:string_rule) { Dry::Validation::Rule.new(:name, is_string) }

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

    describe '#compose' do
      it 'returns pipelined rule where value is passed to the right' do
        present_and_string = presence_rule.compose(string_rule)

        expect(present_and_string.(name: 'Jane')).to be_success

        expect(present_and_string.({})).to be_failure
        expect(present_and_string.(name: 1)).to be_failure
      end
    end
  end
end
