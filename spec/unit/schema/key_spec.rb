RSpec.describe Schema::Key do
  include_context 'predicate helper'

  let(:registry) { PredicateRegistry.new(predicates) }

  describe '#str?' do
    subject(:user) { Schema::Key[:user, registry: registry] }

    it 'returns a key rule' do
      expect(user.str?.to_ast).to eql(
        [:rule, [:user, [:key, [:user, [:predicate, [:str?, [[:input, Undefined]]]]]]]]
      )
    end

    it 'returns a key rule & disjunction rule created within the block' do
      user.hash? do
        required(:email) { none? | filled? }
      end

      expect(user.to_ast).to eql(
        [:key, [:user, [:rule, [:user,
          [:and, [
            [:rule, [:user, [:predicate, [:hash?, [[:input, Undefined]]]]]],
            [:rule, [:user, [:key, [:user, [:rule, [:email,
              [:and, [
                [:rule, [:email, [:predicate, [:key?, [[:name, :email], [:input, Undefined]]]]]],
                [:rule, [:user, [:rule, [:email,
                  [:or, [
                    [:rule, [:email, [:key, [:email, [:predicate, [:none?, [[:input, Undefined]]]]]]]],
                    [:rule, [:email, [:key, [:email, [:predicate, [:filled?, [[:input, Undefined]]]]]]]]
                  ]]]]]]
              ]]]]]]]
            ]]]
        ]]]]
      )
    end
  end
end
