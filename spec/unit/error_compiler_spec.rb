require 'dry/validation/error_compiler'

RSpec.describe Dry::Validation::ErrorCompiler do
  subject(:error_compiler) { Dry::Validation::ErrorCompiler.new(config) }

  let(:config) do
    {
      errors: {
        str?: "%{value} is not a string"
      }
    }
  end

  describe '#call' do
    let(:ast) do
      [
        [
          :error, [
            [:input, 123],
            [:rule, [:email, [:predicate, [:str?, []]]]]
          ]
        ]
      ]
    end

    it 'converts error ast into another format' do
      expect(error_compiler.(ast)).to eql([[:email, ["123 is not a string"]]])
    end
  end
end
