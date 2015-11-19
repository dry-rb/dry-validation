require 'dry/validation/predicates'

RSpec.shared_examples 'predicates' do
  let(:nil?) { Dry::Validation::Predicates[:nil?] }

  let(:str?) { Dry::Validation::Predicates[:str?] }

  let(:min_size?) { Dry::Validation::Predicates[:min_size?] }

  let(:key?) { Dry::Validation::Predicates[:key?] }
end

RSpec.shared_examples 'a passing predicate' do
  let(:predicate) { Dry::Validation::Predicates[predicate_name] }

  it do
    arguments_list.each do |args|
      expect(predicate.call(*args)).to be true
    end
  end
end

RSpec.shared_examples 'a failing predicate' do
  let(:predicate) { Dry::Validation::Predicates[predicate_name] }

  it do
    arguments_list.each do |args|
      expect(predicate.call(*args)).to be false
    end
  end
end
