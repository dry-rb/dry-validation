require 'dry/validation/rule_compiler'

RSpec.describe Dry::Validation::RuleCompiler, '#call' do
  subject(:compiler) { RuleCompiler.new }

  it 'compiles to key rules' do
    predicate = double(:predicate).as_null_object

    ast = [[:key_rule, [:email, [:predicate, [:key?, predicate]]]]]

    rule = Rule::Key.new(:email, predicate)
    rules = compiler.(ast)

    expect(rules).to eql([rule])
  end
end
