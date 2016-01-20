RSpec.describe Schema::Rule do
  let(:filled) { [:val, [:email, [:predicate, [:filled?, []]]]] }
  let(:format) { [:val, [:email, [:predicate, [:format?, [/regex/]]]]] }

  let(:left) { Schema::Rule.new(:email, filled) }
  let(:right) { Schema::Rule.new(:email, format) }

  describe '#and' do
    it 'returns a conjunction' do
      expect(left.and(right).to_ary).to match_array([:and, [filled, format]])
    end
  end

  describe '#or' do
    it 'returns a disjunction' do
      expect(left.or(right).to_ary).to match_array([:or, [filled, format]])
    end
  end

  describe '#xor' do
    it 'returns an exclusive disjunction' do
      expect(left.xor(right).to_ary).to match_array([:xor, [filled, format]])
    end
  end

  describe '#then' do
    it 'returns an implication' do
      expect(left.then(right).to_ary).to match_array([:implication, [filled, format]])
    end
  end
end
