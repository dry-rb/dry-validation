require 'dry/validation/input_type_compiler'

RSpec.describe Dry::Validation::InputTypeCompiler, '#call' do
  subject(:compiler) { Dry::Validation::InputTypeCompiler.new }

  let(:rule_ast) do
    [
      Rule::Key.new(:email, Predicates[:key?]),
      Rule::Key.new(:age, Predicates[:key?])
    ].map(&:to_ary)
  end

  let(:params) do
    { 'email' => 'jane@doe.org', 'age' => 20 }
  end

  it 'builds an input dry-data type' do
    input_type = compiler.(rule_ast)

    expect(input_type[params]).to eql(email: 'jane@doe.org', age: 20)
  end
end
