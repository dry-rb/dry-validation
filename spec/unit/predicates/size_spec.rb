require 'dry/validation/predicates'

RSpec.describe Dry::Validation::Predicates do
  describe '#size?' do
    let(:predicate_name) { :size? }

    context 'when value size is equal to n' do
      let(:arguments_list) do
        [
          [[8], 2],
          [4, 'Jill'],
          [2, { 1 => 'st', 2 => 'nd' }],
          [8, 8],
          [1..8, 5]
        ]
      end

      it_behaves_like 'a passing predicate'
    end

    context 'when value size is greater than n' do
      let(:arguments_list) do
        [
          [[1, 2], 3],
          [5, 'Jill'],
          [3, { 1 => 'st', 2 => 'nd' }],
          [1, 9],
          [1..5, 6]
        ]
      end

      it_behaves_like 'a failing predicate'
    end

    context 'with value size is less than n' do
      let(:arguments_list) do
        [
          [[1, 2], 1],
          [3, 'Jill'],
          [1, { 1 => 'st', 2 => 'nd' }],
          [1, 7],
          [1..5, 4]
        ]
      end

      it_behaves_like 'a failing predicate'
    end

    context 'with an unsupported size' do
      it 'raises an error' do
        expect { Predicates[:size?].call('oops', 1) }.to raise_error(ArgumentError, /oops/)
      end
    end
  end
end
