require 'dry/validation/hint_compiler'

RSpec.describe HintCompiler, '#call' do
  subject(:compiler) { HintCompiler.new(Messages.default, rules: rules) }

  let(:rules) do
    [
      [
        :and, [
          [:key, [:age, [:predicate, [:key?, []]]]],
          [
            :or, [
              [:val, [:age, [:predicate, [:none?, []]]]],
              [
                :and, [
                  [:val, [:age, [:predicate, [:int?, []]]]],
                  [:val, [:age, [:predicate, [:gt?, [18]]]]]
                ]
              ]
            ]
          ]
        ],
      ],
      [
        :and, [
          [:attr, [:height, [:predicate, [:attr?, []]]]],
          [
            :or, [
              [:val, [:height, [:predicate, [:none?, []]]]],
              [
                :and, [
                  [:val, [:height, [:predicate, [:int?, []]]]],
                  [:val, [:height, [:predicate, [:gt?, [180]]]]]
                ]
              ]
            ]
          ]
        ]
      ]
    ]
  end

  it 'returns hint messages for given rules' do
    expect(compiler.call).to eql(
      age: ['age must be an integer', 'age must be greater than 18'],
      height: ['height must be an integer', 'height must be greater than 180'],
    )
  end
end
