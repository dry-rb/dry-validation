require 'dry/validation/error_compiler'

RSpec.describe Dry::Validation::ErrorCompiler do
  subject(:error_compiler) { Dry::Validation::ErrorCompiler.new(config) }

  let(:config) do
    {
      errors: {
        gt?: "%{name} must be greater than %{num} (%{value} was given)",
        filled?: "%{name} must be filled"
      }
    }
  end

  describe '#call' do
    let(:ast) do
      [
        [:error, [:input, [:age, 18, [:rule, [:age, [:predicate, [:gt?, [18]]]]]]]],
        [:error, [:input, [:email, "", [:rule, [:email, [:predicate, [:filled?, []]]]]]]]
      ]
    end

    it 'converts error ast into another format' do
      expect(error_compiler.(ast)).to eql([
        [:age, ["age must be greater than 18 (18 was given)"]],
        [:email, ["email must be filled"]]
      ])
    end
  end
end
