RSpec.describe Schema::Rule do
  include_context 'predicate helper'

  let(:filled) { [:val, [:email, p(:filled?)]] }
  let(:format) { [:val, [:email, p(:format?, /regex/)]] }

  let(:left) { Schema::Rule.new(filled, name: :email, target: target) }
  let(:right) { Schema::Rule.new(format, name: :email, target: target) }
  let(:target) { double(:target, id: :user) }

  describe '#and' do
    it 'returns a conjunction' do
      expect(left.and(right).to_ast).to match_array([:and, [filled, format]])
    end
  end

  describe '#or' do
    it 'returns a disjunction' do
      expect(left.or(right).to_ast).to match_array([:or, [filled, format]])
    end
  end

  describe '#xor' do
    it 'returns an exclusive disjunction' do
      expect(left.xor(right).to_ast).to match_array([:xor, [filled, format]])
    end
  end

  describe '#then' do
    it 'returns an implication' do
      expect(left.then(right).to_ast).to match_array([:implication, [filled, format]])
    end
  end
end
