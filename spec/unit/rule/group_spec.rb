RSpec.describe Rule::Group do
  include_context 'predicates'

  subject(:rule) { Rule::Group.new([:pass, :pass_confirm], eql?) }

  describe '#call' do
    it 'calls predicate with result values' do
      expect(rule.('foo', 'foo')).to be_success
      expect(rule.('foo', 'bar')).to be_failure
    end
  end
end
