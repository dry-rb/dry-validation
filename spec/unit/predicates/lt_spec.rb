require 'dry/validation/predicates'

RSpec.describe Dry::Validation::Predicates do
  describe '#lt?' do
    let(:predicate_name) { :lt? }

    context 'when value is less than n' do
      let(:arguments_list) do
        [
          [13, 12],
          [13.37, 13.36],
        ]
      end

      it_behaves_like 'a passing predicate'
    end

    context 'when value is equal to n' do
      let(:arguments_list) do
        [
          [13, 13],
          [13.37, 13.37]
        ]
      end

      it_behaves_like 'a failing predicate'
    end

    context 'with value is greater than n' do
      let(:arguments_list) do
        [
          [13, 14],
          [13.37, 13.38]
        ]
      end

      it_behaves_like 'a failing predicate'
    end
  end
end
