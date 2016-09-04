RSpec.describe Dry::Validation::MessageCompiler, '#visit_failure' do
  include_context :message_compiler

  let(:visitor) { :visit_failure }

  context 'with :int? predicate' do
    let(:node) do
      [:age, [:key, [:age, [:predicate, [:int?, [[:input, '17']]]]]]]
    end

    it 'returns a message for :int? failure with :rule name inferred from key-rule' do
      expect(result.rule).to be(:age)
      expect(result.path).to eql([:age])
      expect(result).to eql('must be an integer')
    end
  end

  context 'with set failure and :int? predicate' do
    let(:node) do
      [:items, [:key, [:items, [:set, [
        [:key, [0, [:predicate, [:int?, [[:input, 'foo']]]]]],
        [:key, [2, [:predicate, [:int?, [[:input, 'bar']]]]]]
      ]]]]]
    end

    it 'returns a message for the first element that failed' do
      expect(result[0].rule).to be(:items)
      expect(result[0].path).to eql([:items, 0])
      expect(result[0]).to eql('must be an integer')
    end

    it 'returns a message for the third element that failed' do
      expect(result[1].rule).to be(:items)
      expect(result[1].path).to eql([:items, 2])
      expect(result[1]).to eql('must be an integer')
    end
  end
end
