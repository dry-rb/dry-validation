require 'dry/validation/hint_compiler'

RSpec.describe HintCompiler, '#call' do
  subject(:compiler) { HintCompiler.new(Messages.default, rules: rules) }

  include_context 'predicate helper'

  let(:rules) do
    [
      [
        :and, [
          [:val, p(:key?, :age)],
          [
            :or, [
              [:key, [:age, p(:none?)]],
              [
                :and, [
                  [:key, [:age, p(:int?)]],
                  [:key, [:age, p(:gt?, 18)]]
                ]
              ]
            ]
          ]
        ],
      ],
      [
        :and, [
          [:val, p(:key?, :height)],
          [
            :or, [
              [:key, [:height, p(:none?)]],
              [
                :and, [
                  [:key, [:height, p(:int?)]],
                  [:key, [:height, p(:gt?, 180)]]
                ]
              ]
            ]
          ]
        ]
      ]
    ]
  end

  it 'returns hint messages for given rules' do
    expect(compiler.call.to_h).to eql(
      age: ['must be greater than 18'],
      height: ['must be greater than 180'],
    )
  end
end
