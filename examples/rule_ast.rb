require 'dry-validation'

ast = [
  [
    :and,
    [
      [:key, [:age, [:predicate, [:key?, []]]]],
      [
        :and,
        [
          [:val, [:age, [:predicate, [:filled?, []]]]],
          [:val, [:age, [:predicate, [:gt?, [18]]]]]
        ]
      ]
    ]
  ]
]

compiler = Dry::Validation::RuleCompiler.new(Dry::Validation::Predicates)

rules = compiler.call(ast)

puts rules.inspect

puts rules.map(&:to_ary).inspect
