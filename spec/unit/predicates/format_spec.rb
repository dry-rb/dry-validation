require 'dry/validation/predicates'

RSpec.describe Dry::Validation::Predicates, '#format?' do
  let(:predicate_name) { :format? }

  context 'when value matches provided regexp' do
    let(:arguments_list) do
      [['Foo', /^F/]]
    end

    it_behaves_like 'a passing predicate'
  end

  context 'when value does not match provided regexp' do
    let(:arguments_list) do
      [['Bar', /^F/]]
    end

    it_behaves_like 'a failing predicate'
  end
end
