require 'dry/validation/rule_compiler'

RSpec.describe Dry::Validation::RuleCompiler, '#call' do
  subject(:compiler) { RuleCompiler.new }

  let(:predicate) { double(:predicate).as_null_object }

  let(:key_rule) { Rule::Key.new(:email, predicate) }
  let(:val_rule) { Rule::Value.new(:email, predicate) }
  let(:and_rule) { key_rule & val_rule }
  let(:or_rule) { key_rule | val_rule }

  it 'compiles key rules' do
    ast = [[:key_rule, [:email, [:predicate, [:key?, predicate]]]]]

    rules = compiler.(ast)

    expect(rules).to eql([key_rule])
  end

  it 'compiles conjunction rules' do
    ast = [
      [
        :and, [
          [:key_rule, [:email, [:predicate, [:key?, predicate]]]],
          [:val_rule, [:email, [:predicate, [:filled?, predicate]]]]
        ]
      ]
    ]

    rules = compiler.(ast)

    expect(rules).to eql([and_rule])
  end

  it 'compiles disjunction rules' do
    ast = [
      [
        :or, [
          [:key_rule, [:email, [:predicate, [:key?, predicate]]]],
          [:val_rule, [:email, [:predicate, [:filled?, predicate]]]]
        ]
      ]
    ]

    rules = compiler.(ast)

    expect(rules).to eql([or_rule])
  end
end
