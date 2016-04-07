RSpec.describe Schema::Value do
  include_context 'rule compiler'

  describe '#key' do
    subject(:value) { Schema::Value.new }

    let(:expected_ast) do
      [:and, [
        [:val, [:predicate, [:key?, [:address]]]],
        [:key, [:address, [:predicate, [:filled?, []]]]]
      ]]
    end

    it 'creates a rule for a specified key using a block' do
      rule = value.key(:address, &:filled?)

      expect(rule.to_ast).to eql(expected_ast)
    end

    it 'creates a rule for a specified key using a macro' do
      rule = value.key(:address).not_nil

      expect(rule.to_ast).to eql(expected_ast)
    end
  end

  describe '#key deeply nested' do
    subject(:value) { Schema::Value.new }

    let(:expected_ast) do
      [:and, [
        [:val, [:predicate, [:key?, [:address]]]],
        [:key, [:address,
          [:and, [
            [:val, [:predicate, [:key?, [:location]]]],
            [:key, [:location,
              [:set, [
                [:and, [
                  [:val, [:predicate, [:key?, [:lat]]]],
                  [:key, [:lat, [:predicate, [:filled?, []]]]]]
                ],
                [:and, [
                  [:val, [:predicate, [:key?, [:lng]]]],
                  [:key, [:lng, [:predicate, [:filled?, []]]]]
                ]]
              ]]
            ]]]
        ]]]
      ]]
    end

    it 'creates a rule for specified keys using blocks' do
      rule = value.key(:address) do
        required(:location) do
          required(:lat) { filled? }
          required(:lng) { filled? }
        end
      end

      expect(rule.to_ast).to eql(expected_ast)
    end

    it 'creates a rule for specified keys using macros' do
      rule = value.key(:address) do
        required(:location) do
          required(:lat).not_nil
          required(:lng).not_nil
        end
      end

      expect(rule.to_ast).to eql(expected_ast)
    end
  end

  describe '#key with multiple inner-keys' do
    subject(:value) { Schema::Value.new }

    let(:expected_ast) do
      [:and, [
        [:val, [:predicate, [:key?, [:address]]]],
        [:key, [:address, [:set, [
          [:and, [
            [:val, [:predicate, [:key?, [:city]]]],
            [:key, [:city, [:predicate, [:filled?, []]]]]]
          ],
          [:and, [
            [:val, [:predicate, [:key?, [:zipcode]]]],
            [:key, [:zipcode, [:predicate, [:filled?, []]]]]
          ]]
        ]]]]
      ]]
    end

    it 'creates a rule for specified keys using blocks' do
      rule = value.key(:address) do
        required(:city) { filled? }
        required(:zipcode) { filled? }
      end

      expect(rule.to_ast).to eql(expected_ast)
    end

    it 'creates a rule for specified keys using macros' do
      rule = value.key(:address) do
        required(:city).not_nil
        required(:zipcode).not_nil
      end

      expect(rule.to_ast).to eql(expected_ast)
    end
  end

  describe '#each' do
    subject(:value) { Schema::Value.new }

    it 'creates an each rule with another rule returned from the block' do
      rule = value.each { key?(:method) }

      expect(rule.to_ast).to eql(
        [:and, [
          [:val, [:predicate, [:array?, []]]],
          [:each, [:set, [[:val, [:predicate, [:key?, [:method]]]]]]]
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
          [:val, [:predicate, [:array?, []]]],
          [:each,
            [:set, [
              [:and, [
                [:val, [:predicate, [:key?, [:method]]]],
                [:key, [:method, [:predicate, [:str?, []]]]]
              ]],
              [:and, [
                [:val, [:predicate, [:key?, [:amount]]]],
                [:key, [:amount, [:predicate, [:float?, []]]]]
              ]]
            ]]]
        ]]
      )
    end
  end

  describe '#hash? with block' do
    subject(:user) { Schema::Value.new }

    it 'builds hash? & rule created within the block' do
      rule = user.hash? { required(:email).not_nil }

      expect(rule.to_ast).to eql([
        :and, [
          [:val, [:predicate, [:hash?, []]]],
          [:and, [
            [:val, [:predicate, [:key?, [:email]]]],
            [:key, [:email, [:predicate, [:filled?, []]]]]
          ]]
        ]
      ])
    end

    it 'builds hash? & rule created within the block with deep nesting' do
      rule = user.hash? do
        required(:address) do
          hash? do
            required(:city).not_nil
            required(:zipcode).not_nil
          end
        end
      end

      expect(rule.to_ast).to eql(
        [:and, [
          [:val, [:predicate, [:hash?, []]]],
          [:and, [
            [:val, [:predicate, [:key?, [:address]]]],
            [:and, [
              [:val, [:predicate, [:hash?, []]]],
              [:key, [
                :address, [:set, [
                  [:and, [
                    [:val, [:predicate, [:key?, [:city]]]],
                    [:key, [:city, [:predicate, [:filled?, []]]]]]],
                  [:and, [
                    [:val, [:predicate, [:key?, [:zipcode]]]],
                    [:key, [:zipcode, [:predicate, [:filled?, []]]]]]]
                ]]
              ]]
            ]]
          ]]
        ]]
      )
    end
  end

  describe '#not' do
    subject(:user) { Schema::Value.new }

    it 'builds a negated rule' do
      not_email = user.key(:email) { str?.not }

      expect(not_email.to_ast).to eql([
        :and, [
          [:val, [:predicate, [:key?, [:email]]]],
          [:not, [:key, [:email, [:predicate, [:str?, []]]]]]
        ]
      ])
    end
  end
end
