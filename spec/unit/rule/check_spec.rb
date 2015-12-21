RSpec.describe Rule::Check do
  subject(:rule) { Rule::Check.new(:name, other.(input).curry(predicate)) }

  include_context 'predicates'

  let(:other) do
    Rule::Value.new(:name, none?).or(Rule::Value.new(:name, filled?))
  end

  describe '#call' do
    context 'when a given predicate passed' do
      let(:input) { 'Jane' }
      let(:predicate) { :filled? }

      it 'returns a success' do
        expect(rule.()).to be_success
      end
    end

    context 'when a given predicate did not pass' do
      let(:input) { nil }
      let(:predicate) { :filled? }

      it 'returns a failure' do
        expect(rule.()).to be_failure
      end
    end
  end
end
