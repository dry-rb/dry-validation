RSpec.describe Schema::Key do
  describe '#key?' do
    it 'returns a key rule' do
      user = Schema::Key.new(:user, Schema::Buffer.new(:user))
      rule = user.key?

      expect(rule.to_ast).to eql([:key, [:user, [:predicate, [:key?, []]]]])
    end

    it 'returns a key rule & set rule created within the block' do
      user = Schema::Key.new(:user, Schema::Buffer.new(:user))

      rules = user.key? do |value|
        value.key(:email).required
        value.key(:age).maybe
      end

      expect(rules.to_ast[0]).to eql([
        :and, [
          [:key, [:user, [:predicate, [:key?, []]]]],
          [:set, [
            :user, [
              [:and, [
                [:key, [:email, [:predicate, [:key?, []]]]],
                [:val, [:email, [:predicate, [:filled?, []]]]]]
              ],
              [:and, [
                [:key, [:age, [:predicate, [:key?, []]]]],
                [:or, [
                  [:val, [:age, [:predicate, [:none?, []]]]],
                  [:val, [:age, [:predicate, [:filled?, []]]]]]]]
              ]]]
          ]
        ]
      ])
    end

    it 'returns a key rule & disjunction rule created within the block' do
      user = Schema::Key.new(:user, Schema::Value.new(:account))

      rule = user.key? do |value|
        value.key(:email) { |email| email.none? | email.filled? }
      end

      expect(rule.to_ast).to eql([
        :and, [
          [:key, [:user, [:predicate, [:key?, []]]]],
          [:and, [
            [:key, [:email, [:predicate, [:key?, []]]]],
            [:or, [
              [:val, [:email, [:predicate, [:none?, []]]]],
              [:val, [:email, [:predicate, [:filled?, []]]]]]
            ]]
          ]
        ]
      ])
    end
  end
end
