RSpec.describe Schema::Value do
  describe '#key' do
    subject(:value) { Schema::Value.new(:user) }

    let(:expected_ast) do
      [:and, [
        [:key, [:address, [:predicate, [:key?, []]]]],
        [:val, [[:user, :address], [:predicate, [:filled?, []]]]]
      ]]
    end

    it 'creates a rule for a specified key using a block' do
      value.key(:address, &:filled?)

      expect(value.to_ast).to eql(expected_ast)
    end

    it 'creates a rule for a specified key using a macro' do
      value.key(:address).required

      expect(value.to_ast).to eql(expected_ast)
    end
  end

  describe '#each' do
    subject(:value) { Schema::Value.new(:payments) }

    it 'creates an each rule with another rule returned from the block' do
      rule = value.each do |element|
        element.key?(:method)
      end

      expect(rule.to_ast).to eql(
        [:each, [
          :payments, [:val, [:payments, [:predicate, [:key?, [:method]]]]]]
        ]
      )
    end

    it 'creates an each rule with other rules returned from the block' do
      rule = value.each do |element|
        element.key(:method) { |method| method.str? }
        element.key(:amount) { |amount| amount.float? }
      end

      expect(rule.to_ast).to eql(
        [:each, [
          :payments, [
            :set, [
              :payments, [
                [:and, [
                  [:key, [:method, [:predicate, [:key?, []]]]],
                  [:val, [[:payments, :method], [:predicate, [:str?, []]]]]
                ]],
                [:and, [
                  [:key, [:amount, [:predicate, [:key?, []]]]],
                  [:val, [[:payments, :amount], [:predicate, [:float?, []]]]]
                ]]
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
            [:val, [[:user, :email], [:predicate, [:filled?, []]]]]
          ]]
        ]
      ])
    end

    it 'builds hash? & rule created within the block with deep nesting' do
      rule = user.hash? do
        user.key(:address) do |address|
          address.hash? do
            address.key(:city).required
            address.key(:zipcode).required
          end
        end
      end

      expect(rule.to_ast).to eql([
        :and, [
          [:val, [:user, [:predicate, [:hash?, []]]]],
          [:and, [
            [:key, [:address, [:predicate, [:key?, []]]]],
            [:and, [
              [:val, [[:user, :address], [:predicate, [:hash?, []]]]],
              [:set, [[:user, :address], [
                [:and, [
                  [:key, [:city, [:predicate, [:key?, []]]]],
                  [:val, [[:user, :address, :city], [:predicate, [:filled?, []]]]]]],
                [:and, [
                  [:key, [:zipcode, [:predicate, [:key?, []]]]],
                  [:val, [[:user, :address, :zipcode], [:predicate, [:filled?, []]]]]
                  ]]
              ]]]
            ]]
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
          [:not, [:val, [[:user, :email], [:predicate, [:str?, []]]]]]
        ]
      ])
    end
  end
end
