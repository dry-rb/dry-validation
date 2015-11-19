require 'dry/validation/predicates'

RSpec.describe Dry::Validation::Predicates do
  describe '#nil?' do
    let(:predicate_name) { :nil? }

    context 'when value is nil' do
      let(:arguments_list) { [[nil]] }
      it_behaves_like 'a passing predicate'
    end

    context 'when value is not nil' do
      let(:arguments_list) do
        [
          [''],
          [true],
          [false],
          [0],
          [:symbol],
          [[]],
          [{}],
          [String]
        ]
      end
      it_behaves_like 'a failing predicate'
    end
  end
end
