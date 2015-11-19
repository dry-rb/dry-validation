require 'dry/validation/rule'

RSpec.describe Dry::Validation::Rule::Set do
  include_context 'predicates'

  subject(:rule) do
    Dry::Validation::Rule::Set.new(:address, [is_string, min_size.curry(6)])
  end

  let(:is_string) { Dry::Validation::Rule::Value.new(:name, str?) }
  let(:min_size) { Dry::Validation::Rule::Value.new(:name, min_size?) }

  describe '#call' do
    it 'applies its rules to the input' do
      expect(rule.('Address')).to be_success
      expect(rule.('Addr')).to be_failure
    end
  end

  describe '#to_ary' do
    it 'returns an array representation' do
      expect(rule).to match_array([
        :rule, [
          :address, [
            :set, [
              [:rule, [:name, [:predicate, [:str?, []]]]],
              [:rule, [:name, [:predicate, [:min_size?, [6]]]]]
            ]
          ]
        ]
      ])
    end
  end
end
