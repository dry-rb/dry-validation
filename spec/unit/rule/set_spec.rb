require 'dry/validation/rule'

RSpec.describe Dry::Validation::Rule::Set do
  include_context 'predicates'

  subject(:address_rule) do
    Dry::Validation::Rule::Set.new([is_string, min_size.curry(6)])
  end

  let(:is_string) { Dry::Validation::Rule::Value.new(:name, str?) }
  let(:min_size) { Dry::Validation::Rule::Value.new(:name, min_size?) }

  describe '#call' do
    it 'applies its rules to the input' do
      expect(address_rule.('Address')).to be_success
      expect(address_rule.('Addr')).to be_failure
    end
  end
end
