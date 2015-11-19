require 'dry/validation/predicates'

RSpec.describe Dry::Validation::Predicates do
  describe '#int?' do
    let(:predicate_name) { :int? }

    context 'when value is an integer' do
      let(:arguments_list) do
        [
          [1],
          [33],
          [7]
        ]
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
          [String]
        ]
      end

      it_behaves_like 'a failing predicate'
    end
  end
end
