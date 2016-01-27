RSpec.describe Schema::Value do
  describe '#key' do
    subject(:value) { Schema::Value.new(:user) }

    it 'creates a rule for a specified key' do
      rule_macro = value.key(:address).required
      rule_block = value.key(:address, &:filled?)

      expect(rule_macro.to_ast).to eql(rule_block.to_ast)
    end
  end

  describe '#each' do
    subject(:value) { Schema::Value.new(:payments) }

    it 'creates an each rule with another rule returned from the block' do
      rule = value.each do
        value.key?(:method)
      end

      expect(rule.to_ast).to eql(
        [:each, [
          :payments, [:val, [:payments, [:predicate, [:key?, [:method]]]]]]
        ]
      )
    end

    it 'creates an each rule with other rules returned from the block' do
      rule = value.each do
        value.key(:method) { |method| method.str? }
        value.key(:amount) { |amount| amount.float? }
      end

      expect(rule.to_ast).to eql(
        [:each, [
          :payments, [
            :set, [
              :payments, [
                [:and, [
                  [:key, [:method, [:predicate, [:key?, []]]]],
                  [:val, [:method, [:predicate, [:str?, []]]]]
                ]],
                [:and, [
                  [:key, [:amount, [:predicate, [:key?, []]]]],
                  [:val, [:amount, [:predicate, [:float?, []]]]]
                ]],
              ]
            ]
          ]
        ]]
      )
    end
  end

  describe '#hash? with block' do
    subject(:user) { Schema::Value.new(:user) }

    it 'builds hash? & rule created within the block' do
      rule = user.hash? { user.key(:email).required }

      expect(rule.to_ast).to eql([
        :and, [
          [:val, [:user, [:predicate, [:hash?, []]]]],
          [:and, [
            [:key, [:email, [:predicate, [:key?, []]]]],
            [:val, [{ user: :email }, [:predicate, [:filled?, []]]]]
          ]]
        ]
      ])
    end
  end

  describe '#not' do
    subject(:user) { Schema::Value.new(:user) }

    it 'builds a negated rule' do
      not_email = user.key(:email) { |email| email.str?.not }

      expect(not_email.to_ast).to eql([
        :and, [
          [:key, [:email, [:predicate, [:key?, []]]]],
          [:not, [:val, [:email, [:predicate, [:str?, []]]]]]
        ]
      ])
    end
  end
end
