RSpec.describe Schema::Value do
  include_context 'rule compiler'
  include_context 'predicate helper'

  let(:registry) { PredicateRegistry.new(predicates) }

  describe '#required' do
    subject(:value) { Schema::Value.new(registry: registry) }

    let(:expected_ast) do
      [:rule, [:address, [:and, [
        [:rule, [:address, [:predicate, [:key?, [[:name, :address], [:input, Undefined]]]]]],
        [:rule, [:address, [:key, [:address, [:predicate, [:filled?, [[:input, Undefined]]]]]]]]
      ]]]]
    end

    it 'creates a rule for a specified key using a block' do
      rule = value.required(:address, &:filled?)
      expect(rule.to_ast).to eql(expected_ast)
    end

    it 'creates a rule for a specified key using a macro' do
      rule = value.required(:address).filled
      expect(rule.to_ast).to eql(expected_ast)
    end
  end

  describe '#each' do
    subject(:value) { Schema::Value.new(registry: registry) }

    it 'creates an each rule with another rule returned from the block' do
      rule = value.each { key?(:method) }

      expect(rule.to_ast).to eql(
        [:and, [
          [:predicate, [:array?, [[:input, Undefined]]]],
          [:each, [:predicate, [:key?, [[:name, :method], [:input, Undefined]]]]]
        ]]
      )
    end

    it 'creates an each rule with other rules returned from the block' do
      rule = value.each do
        required(:method) { str? }
        required(:amount) { float? }
      end

      expect(rule.to_ast).to eql(
        [:and, [
          [:predicate, [:array?, [[:input, Undefined]]]],
          [:each, [:set, [
            [:rule, [:method, [:and, [
              [:rule, [:method, [:predicate, [:key?, [[:name, :method], [:input, Undefined]]]]]],
              [:rule, [:method, [:key, [:method, [:predicate, [:str?, [[:input, Undefined]]]]]]]]]
            ]]],
            [:rule, [:amount, [:and, [
              [:rule, [:amount, [:predicate, [:key?, [[:name, :amount], [:input, Undefined]]]]]],
              [:rule, [:amount, [:key, [:amount, [:predicate, [:float?, [[:input, Undefined]]]]]]]]
            ]]]]
          ]]]
        ]]
      )
    end
  end

  describe '#hash? with block' do
    subject(:user) { Schema::Value.new(registry: registry) }

    it 'builds hash? & rule created within the block' do
      rule = user.hash? { required(:email).filled }

      expect(rule.to_ast).to eql(
        [:and, [
          [:predicate, [:hash?, [[:input, Undefined]]]],
          [:rule, [:email, [:and, [
            [:rule, [:email, [:predicate, [:key?, [[:name, :email], [:input, Undefined]]]]]],
            [:rule, [:email, [:key, [:email, [:predicate, [:filled?, [[:input, Undefined]]]]]]]]
          ]]]]
        ]]
      )
    end

    it 'builds hash? & rule created within the block with deep nesting' do
      rule = user.hash? do
        required(:address) do
          hash? do
            required(:city).filled
            required(:zipcode).filled
          end
        end
      end

      expect(rule.to_ast).to eql(
        [:and, [
          [:predicate, [:hash?, [[:input, Undefined]]]],
          [:rule, [:address, [:and, [
            [:rule, [:address, [:predicate, [:key?, [[:name, :address], [:input, Undefined]]]]]],
            [:rule, [:address, [:and, [
              [:rule, [:address, [:predicate, [:hash?, [[:input, Undefined]]]]]],
              [:rule, [:address, [:key, [:address, [:set, [
                [:rule, [:city, [:and, [
                  [:rule, [:city, [:predicate, [:key?, [[:name, :city], [:input, Undefined]]]]]],
                  [:rule, [:city, [:key, [:city, [:predicate, [:filled?, [[:input, Undefined]]]]]]]]
                ]]]],
                [:rule, [:zipcode, [:and, [
                  [:rule, [:zipcode, [:predicate, [:key?, [[:name, :zipcode], [:input, Undefined]]]]]],
                  [:rule, [:zipcode, [:key, [:zipcode, [:predicate, [:filled?, [[:input, Undefined]]]]]]]]
                ]]]]
              ]]]]]]
            ]]]]
          ]]]]
        ]]
      )
    end
  end

  describe '#not' do
    subject(:user) { Schema::Value.new(registry: registry) }

    it 'builds a negated rule' do
      not_email = user.required(:email) { str?.not }

      expect(not_email.to_ast).to eql(
        [:rule, [:email, [:and, [
          [:rule, [:email, [:predicate, [:key?, [[:name, :email], [:input, Undefined]]]]]],
          [:rule, [:email, [:not, [:key, [:email, [:predicate, [:str?, [[:input, Undefined]]]]]]]]]]
        ]]]
      )
    end
  end
end
