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
# [
#   #<Dry::Validation::Rule::Conjunction
#     left=#<Dry::Validation::Rule::Key name=:age predicate=#<Dry::Validation::Predicate id=:key?>>
#     right=#<Dry::Validation::Rule::Conjunction
#       left=#<Dry::Validation::Rule::Value name=:age predicate=#<Dry::Validation::Predicate id=:filled?>>
#       right=#<Dry::Validation::Rule::Value name=:age predicate=#<Dry::Validation::Predicate id=:gt?>>>>
# ]

puts rules.map(&:to_ary).inspect
# [[:and, [:key, [:age, [:predicate, [:key?, [:age]]]]], [[:and, [:val, [:age, [:predicate, [:filled?, []]]]], [[:val, [:age, [:predicate, [:gt?, [18]]]]]]]]]]
