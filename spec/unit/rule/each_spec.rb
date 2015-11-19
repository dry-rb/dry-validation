require 'dry/validation/rule'

RSpec.describe Dry::Validation::Rule::Each do
  include_context 'predicates'

  subject(:address_rule) do
    Dry::Validation::Rule::Each.new(:name, is_string)
  end

  let(:is_string) { Dry::Validation::Rule::Value.new(:name, str?) }

  describe '#call' do
    it 'applies its rules to all elements in the input' do
      expect(address_rule.(['Address'])).to be_success

      expect(address_rule.([nil, 'Address'])).to be_failure
      expect(address_rule.([:Address, 'Address'])).to be_failure
    end
  end
end
