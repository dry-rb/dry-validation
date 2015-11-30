require 'dry/validation/predicates'

RSpec.describe Dry::Validation::Predicates do
  describe '#float?' do
    let(:predicate_name) { :float? }

    context 'when value is a float' do
      let(:arguments_list) do
        [[1.0]]
      end

      it_behaves_like 'a passing predicate'
    end

    context 'with value is not an integer' do
      let(:arguments_list) do
        [
          [''],
          [[]],
          [{}],
          [nil],
          [:symbol],
          [String],
          [1]
        ]
      end

      it_behaves_like 'a failing predicate'
    end
  end
end
