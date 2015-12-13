require 'dry/validation/rule_compiler'

RSpec.describe Dry::Validation::RuleCompiler, '#call' do
  subject(:compiler) { RuleCompiler.new(predicates) }

  let(:predicates) { { key?: predicate, filled?: predicate } }

  let(:predicate) { double(:predicate).as_null_object }

  let(:key_rule) { Rule::Key.new(:email, predicate) }
  let(:val_rule) { Rule::Value.new(:email, predicate) }
  let(:and_rule) { key_rule & val_rule }
  let(:or_rule) { key_rule | val_rule }
  let(:set_rule) { Rule::Set.new(:email, [val_rule]) }
  let(:each_rule) { Rule::Each.new(:email, val_rule) }

  it 'compiles key rules' do
    ast = [[:key, [:email, [:predicate, [:key?, predicate]]]]]

    rules = compiler.(ast)

    expect(rules).to eql([key_rule])
  end

  it 'compiles conjunction rules' do
    ast = [
      [
        :and, [
          [:key, [:email, [:predicate, [:key?, predicate]]]],
          [:val, [:email, [:predicate, [:filled?, predicate]]]]
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
          [:key, [:email, [:predicate, [:key?, predicate]]]],
          [:val, [:email, [:predicate, [:filled?, predicate]]]]
        ]
      ]
    ]

    rules = compiler.(ast)

    expect(rules).to eql([or_rule])
  end

  it 'compiles set rules' do
    ast = [
      [
        :set, [
          :email, [
            [:val, [:email, [:predicate, [:filled?, predicate]]]]
          ]
        ]
      ]
    ]

    rules = compiler.(ast)

    expect(rules).to eql([set_rule])
  end

  it 'compiles each rules' do
    ast = [
      [
        :each, [
          :email, [:val, [:email, [:predicate, [:filled?, predicate]]]]
        ]
      ]
    ]

    rules = compiler.(ast)

    expect(rules).to eql([each_rule])
  end
end
