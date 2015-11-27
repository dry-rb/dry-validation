require 'dry/validation/input_type_compiler'

RSpec.describe Dry::Validation::InputTypeCompiler, '#call' do
  subject(:compiler) { Dry::Validation::InputTypeCompiler.new }

  let(:rule_ast) do
    [
      [
        :and, [
          [:key, [:email, [:predicate, [:key?, [:email]]]]],
          [
            :and, [
              [:val, [:email, [:predicate, [:str?, []]]]],
              [:val, [:email, [:predicate, [:filled?, []]]]]
            ]
          ]
        ]
      ],
      [
        :and, [
          [:key, [:age, [:predicate, [:key?, [:age]]]]],
          [
            :and, [
              [:val, [:age, [:predicate, [:int?, []]]]],
              [:val, [:age, [:predicate, [:filled?, []]]]]
            ]
          ]
        ]
      ],
      [
        :and, [
          [:key, [:address, [:predicate, [:key?, [:address]]]]],
          [:val, [:address, [:predicate, [:str?, []]]]]
        ]
      ]
    ].map(&:to_ary)
  end

  let(:params) do
    { 'email' => 'jane@doe.org', 'age' => '20', 'address' => 'City, Street 1/2' }
  end

  it 'builds an input dry-data type' do
    input_type = compiler.(rule_ast)

    expect(input_type[params]).to eql(
      'email' => 'jane@doe.org', 'age' => 20, 'address' => 'City, Street 1/2'
    )
  end
end
