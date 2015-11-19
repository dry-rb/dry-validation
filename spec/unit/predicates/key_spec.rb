require 'dry/validation/predicates'

RSpec.describe Dry::Validation::Predicates do
  describe '#key?' do
    let(:predicate_name) { :key? }

    context 'when key is present in value' do
      let(:arguments_list) do
        [
          [:name, { name: 'John' }],
          [:age, { age: 18 }]
        ]
      end

      it_behaves_like 'a passing predicate'
    end

    context 'with key is not present in value' do
      let(:arguments_list) do
        [
          [:name, { age: 18 }],
          [:age, { name: 'Jill' }]
        ]
      end

      it_behaves_like 'a failing predicate'
    end
  end
end
