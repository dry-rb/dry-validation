RSpec.describe Schema::Key do
  describe '#key?' do
    subject(:user) { Schema::Key[:user] }

    it 'returns a key rule' do
      rule = user.key?(:address)

      expect(rule.to_ast).to eql([:key, [:user, [:predicate, [:key?, [:address]]]]])
    end

    it 'returns a key rule & disjunction rule created within the block' do
      user.hash? do
        required(:email) { none? | filled? }
      end

      expect(user.to_ast).to eql([
        :key, [:user, [
          :and, [
            [:val, [:predicate, [:hash?, []]]],
            [:key, [:user, [:and, [
              [:val, [:predicate, [:key?, [:email]]]],
              [:or, [
                [:key, [:email, [:predicate, [:none?, []]]]],
                [:key, [:email, [:predicate, [:filled?, []]]]]]
              ]]
            ]]
            ]
          ]
        ]]
      ])
    end
  end
end
