RSpec.describe Schema::Value do
  describe '#each' do
    subject(:value) { Schema::Value.new(:payments) }

    it 'creates an each rule with another rule returned from the block' do
      rule = value.each do
        value.key?(:method)
      end

      expect(rule.to_ary).to match_array(
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

      expect(rule.to_ary).to match_array(
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

  describe '#rule' do
    subject(:pills) { Schema::Value.new(:pills) }

    it 'appends new check rule' do
      pills.key(:red, &:filled?)
      pills.key(:blue, &:filled?)

      pills.rule(:destiny) { pills.rule(:red) | pills.rule(:blue) }

      expect(pills.checks.map(&:to_ary)).to match_array([
        [
          :check, [
            :destiny, [
              :or, [
                [:check, [:red, [:predicate, [:red, []]]]],
                [:check, [:blue, [:predicate, [:blue, []]]]]
              ]
            ]
          ]
        ]
      ])
    end
  end

  describe '#not' do
    subject(:user) { Schema::Value.new(:user) }

    it 'builds a negated rule' do
      not_email = user.key(:email, &:str?).first.not

      expect(not_email.to_ary).to eql([
        :not, [
          :and, [
            [:key, [:email, [:predicate, [:key?, []]]]],
            [:val, [:email, [:predicate, [:str?, []]]]]
          ]
        ]
      ])
    end
  end
end
