RSpec.describe Schema::Key do
  subject(:user) { Schema::Key.new(:user) }

  describe '#key?' do
    it 'returns a key rule' do
      rule = user.key?(:address)

      expect(rule.to_ast).to eql([:key, [:user, [:predicate, [:key?, [:address]]]]])
    end

    it 'returns a key rule & disjunction rule created within the block' do
      rule = user.hash? do |value|
        value.key(:email) { |email| email.none? | email.filled? }
      end

      expect(rule.to_ast).to eql([
        :key, [:user, [
          :and, [
            [:val, [:predicate, [:hash?, []]]],
            [:and, [
              [:val, [:predicate, [:key?, [:email]]]],
              [:or, [
                [:key, [:email, [:predicate, [:none?, []]]]],
                [:key, [:email, [:predicate, [:filled?, []]]]]]
              ]]
            ]
          ]
        ]]
      ])
    end
  end
end
