require 'dry/validation/predicates'

RSpec.describe Dry::Validation::Predicates do
  describe '#decimal?' do
    let(:predicate_name) { :decimal? }

    context 'when value is a date' do
      let(:arguments_list) do
        [[1.2.to_d]]
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
          [1],
          [1.0]
        ]
      end

      it_behaves_like 'a failing predicate'
    end
  end
end
