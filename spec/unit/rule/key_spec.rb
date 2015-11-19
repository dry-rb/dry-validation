require 'dry/validation/rule'

RSpec.describe Dry::Validation::Rule::Key do
  include_context 'predicates'

  subject(:rule) { Dry::Validation::Rule::Key.new(:name, key?) }

  describe '#call' do
    it 'applies predicate to the value' do
      expect(rule.(name: 'Jane')).to be_success
      expect(rule.({})).to be_failure
    end
  end

  describe '#and' do
    let(:other) { Dry::Validation::Rule::Value.new(:name, str?) }

    it 'returns conjunction rule where value is passed to the right' do
      present_and_string = rule.and(other)

      expect(present_and_string.(name: 'Jane')).to be_success

      expect(present_and_string.({})).to be_failure
      expect(present_and_string.(name: 1)).to be_failure
    end
  end
end
