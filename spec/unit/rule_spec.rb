RSpec.describe Rule do
  describe '#call' do
    subject(:rule) { Rule.new(:name, predicate) }

    let(:predicate) { -> { true } }

    it 'returns result of its predicate' do
      expect(rule.call).to be_success
    end
  end

  describe 'composition' do
    let(:left) { Rule.new(:left, -> { true }) }
    let(:right) { Rule.new(:left, -> { false }) }

    describe '#and' do
      it 'returns a conjunction' do
        expect(left.and(right).call).to be_failure
      end
    end

    describe '#or' do
      it 'returns a conjunction' do
        expect(left.or(right).call).to be_success
      end
    end

    describe '#then' do
      it 'returns an implication' do
        expect(left.then(right).call).to be_failure
      end
    end
  end
end
