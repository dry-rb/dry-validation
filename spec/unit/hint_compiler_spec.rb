require 'dry/validation/hint_compiler'

RSpec.describe HintCompiler, '#call' do
  subject(:compiler) { HintCompiler.new(Messages.default) }

  let(:rules) do
    [[
      :and, [
        [:key, [:email, [:predicate, [:key?, []]]]],
        [:val, [:email, [:predicate, [:str?, []]]]]
      ]
    ]]
  end

  it 'returns hint messages for given rules' do
    expect(compiler.(rules)).to eql(email: ['email must be a string'])
  end
end
