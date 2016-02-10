require 'dry/logic/rule_compiler'
require 'dry/logic/predicates'

RSpec.shared_context 'rule compiler' do
  let(:rule_compiler) do
    Dry::Logic::RuleCompiler.new(Dry::Logic::Predicates)
  end
end
