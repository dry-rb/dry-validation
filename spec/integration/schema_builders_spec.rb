RSpec.describe 'Building schemas' do
  describe 'Dry::Validation.Schema' do
    it 'builds a schema class with custom predicate set' do
      predicates = Module.new do
        include Dry::Logic::Predicates

        predicate(:zomg?) { true }
      end

      schema = Dry::Validation.Schema(predicates: predicates, build: false)

      expect(schema.predicates.key?(:zomg?)).to be(true)
    end
  end
end
