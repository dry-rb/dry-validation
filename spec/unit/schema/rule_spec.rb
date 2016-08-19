RSpec.describe Schema::Rule do
  include_context 'predicate helper'

  let(:filled) { p(:filled?) }
  let(:format) { p(:format?, /regex/) }

  let(:left) { Schema::Rule.new(filled, name: :email, target: target) }
  let(:right) { Schema::Rule.new(format, name: :email, target: target) }
  let(:target) { double(:target, id: :user) }

  describe '#and' do
    it 'returns a conjunction' do
      expect(left.and(right).to_ast).to match_array(
        [:rule, [:email, [:and, [[:rule, [:email, filled]], [:rule, [:email, format]]]]]]
      )
    end
  end

  describe '#or' do
    it 'returns a disjunction' do
      expect(left.or(right).to_ast).to match_array(
        [:rule, [:email, [:or, [[:rule, [:email, filled]], [:rule, [:email, format]]]]]]
      )
    end
  end

  describe '#xor' do
    it 'returns an exclusive disjunction' do
      expect(left.xor(right).to_ast).to match_array(
        [:rule, [:email, [:xor, [[:rule, [:email, filled]], [:rule, [:email, format]]]]]]
      )
    end
  end

  describe '#then' do
    it 'returns an implication' do
      expect(left.then(right).to_ast).to match_array(
        [:rule, [:email, [:implication, [[:rule, [:email, filled]], [:rule, [:email, format]]]]]]
      )
    end
  end
end
