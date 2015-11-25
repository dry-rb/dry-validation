require 'dry/validation/predicates'

RSpec.describe Dry::Validation::Predicates, '#eql?' do
  let(:predicate_name) { :eql? }

  context 'when value is equal to the arg' do
    let(:arguments_list) do
      [['Foo', 'Foo']]
    end

    it_behaves_like 'a passing predicate'
  end

  context 'with value is not empty' do
    let(:arguments_list) do
      [['Bar', 'Foo']]
    end

    it_behaves_like 'a failing predicate'
  end
end
