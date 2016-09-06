require 'dry/validation/predicate_registry'

RSpec.describe PredicateRegistry do
  subject!(:predicate_registry) { schema_class.registry }

  let(:schema_class) { Class.new(Schema) }
  let(:schema) { schema_class.new }

  before do
    schema_class.class_eval { def dis_ok?; true; end }
  end

  describe '.[]' do
    it 'returns a registry which collects predicate methods' do
      expect(predicate_registry[:dis_ok?]).to be_instance_of(UnboundMethod)
    end
  end

  describe '#[]' do
    it 'gives access to built-in predicates' do
      expect(predicate_registry[:filled?].("sutin")).to be(true)
    end
  end

  describe '#bind' do
    it 'binds unbound predicates and return finalized registry' do
      registry = predicate_registry.bind(schema)

      expect(registry).to be_frozen
      expect(registry[:dis_ok?]).to be_a(Method)
      expect(registry[:dis_ok?].()).to be(true)
    end
  end
end
