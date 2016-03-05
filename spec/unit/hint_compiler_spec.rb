require 'dry/validation/hint_compiler'

RSpec.describe HintCompiler, '#call' do
  subject(:compiler) { HintCompiler.new(Messages.default, rules: rules) }

  let(:rules) do
    [
      [
        :and, [
          [:val, [:predicate, [:key?, [:age]]]],
          [
            :or, [
              [:key, [:age, [:predicate, [:none?, []]]]],
              [
                :and, [
                  [:key, [:age, [:predicate, [:int?, []]]]],
                  [:key, [:age, [:predicate, [:gt?, [18]]]]]
                ]
              ]
            ]
          ]
        ],
      ],
      [
        :and, [
          [:val, [:predicate, [:attr?, [:height]]]],
          [
            :or, [
              [:attr, [:height, [:predicate, [:none?, []]]]],
              [
                :and, [
                  [:attr, [:height, [:predicate, [:int?, []]]]],
                  [:attr, [:height, [:predicate, [:gt?, [180]]]]]
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
      age: ['age must be greater than 18'],
      height: ['height must be greater than 180'],
    )
  end
end
