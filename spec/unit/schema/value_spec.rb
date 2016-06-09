RSpec.describe Schema::Value do
  include_context 'rule compiler'
  include_context 'predicate helper'

  let(:registry) { PredicateRegistry.new(predicates) }

  describe '#required' do
    subject(:value) { Schema::Value.new(registry: registry) }

    let(:expected_ast) do
      [:and, [
        [:val, p(:key?, :address)],
        [:key, [:address, p(:filled?)]]
      ]]
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
          [:val, p(:array?)],
          [:each, [:val, p(:key?, :method)]]
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
          [:val, p(:array?)],
          [:each,
            [:set, [
              [:and, [
                [:val, p(:key?, :method)],
                [:key, [:method, p(:str?)]]
              ]],
              [:and, [
                [:val, p(:key?, :amount)],
                [:key, [:amount, p(:float?)]]
              ]]
            ]]]
        ]]
      )
    end
  end

  describe '#hash? with block' do
    subject(:user) { Schema::Value.new(registry: registry) }

    it 'builds hash? & rule created within the block' do
      rule = user.hash? { required(:email).filled }

      expect(rule.to_ast).to eql([
        :and, [
          [:val, p(:hash?)],
          [:and, [
            [:val, p(:key?, :email)],
            [:key, [:email, p(:filled?)]]
          ]]
        ]
      ])
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
          [:val, p(:hash?)],
          [:and, [
            [:val, p(:key?, :address)],
            [:and, [
              [:val, p(:hash?)],
              [:key, [
                :address, [:set, [
                  [:and, [
                    [:val, p(:key?, :city)],
                    [:key, [:city, p(:filled?)]]]],
                  [:and, [
                    [:val, p(:key?, :zipcode)],
                    [:key, [:zipcode, p(:filled?)]]]]
                ]]
              ]]
            ]]
          ]]
        ]]
      )
    end
  end

  describe '#not' do
    subject(:user) { Schema::Value.new(registry: registry) }

    it 'builds a negated rule' do
      not_email = user.required(:email) { str?.not }

      expect(not_email.to_ast).to eql([
        :and, [
          [:val, p(:key?, :email)],
          [:not, [:key, [:email, p(:str?)]]]
        ]
      ])
    end
  end
end
