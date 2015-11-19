require 'dry/validation/predicates'

RSpec.shared_examples 'predicates' do
  let(:nil?) { Dry::Validation::Predicates[:nil?] }

  let(:str?) { Dry::Validation::Predicates[:str?] }

  let(:min_size?) { Dry::Validation::Predicates[:min_size?] }

  let(:key?) { Dry::Validation::Predicates[:key?] }
end
