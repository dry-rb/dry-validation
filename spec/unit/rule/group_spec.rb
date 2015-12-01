RSpec.describe Rule::Group do
  include_context 'predicates'

  subject(:rule) { Rule::Group.new([:pass, :pass_confirm], eql?) }

  let(:pass) { Rule::Value.new(:pass, str?) }
  let(:pass_confirm) { Rule::Value.new(:pass_confirm, str?) }

  describe '#call' do
    it 'calls predicate with result values' do
      result = [pass.('foo'), pass_confirm.('foo')]

      expect(rule.(result)).to be_success

      result = [pass.('foo'), pass_confirm.('bar')]

      expect(rule.(result)).to be_failure
    end
  end
end
