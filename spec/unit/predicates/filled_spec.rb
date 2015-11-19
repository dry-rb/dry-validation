require 'dry/validation/predicates'

RSpec.describe Dry::Validation::Predicates do
  describe '#filled?' do
    let(:predicate_name) { :filled? }

    context 'when value is filled' do
      let(:arguments_list) do
        [
          ['Jill'],
          [[1, 2, 3]],
          [{ name: 'John' }],
          [true],
          [false],
          ['1'],
          ['0'],
          [:symbol],
          [String]
        ]
      end

      it_behaves_like 'a passing predicate'
    end

    context 'with value is not filled' do
      let(:arguments_list) do
        [
          [''],
          [[]],
          [{}],
          [nil]
        ]
      end

      it_behaves_like 'a failing predicate'
    end
  end
end
