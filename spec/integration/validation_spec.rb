RSpec.describe Dry::Validation do
  before do
    module Test
      class Predicates
        extend Dry::Container::Mixin

        register(:value?) do
          Dry::Validation::Predicate.new do |name, input|
            input.key?(name)
          end
        end

        register(:empty?) do
          Dry::Validation::Predicate.new do |input|
            case input
            when String, Array, Hash then input.empty?
            when nil then true
            else
              false
            end
          end
        end

        register(:filled?, self[:empty?].inversed)

        register(:present?) do
          Dry::Validation::Predicate.new do |name, input|
            self[:value?].(name, input) & self[:filled?].(input[name])
          end
        end
      end

      class Validation < Dry::Validation::Schema
        configure do |config|
          config.predicates = Predicates
        end

        attribute :name, :present?
      end
    end
  end

  describe 'defining predicates' do
    it 'works' do
      expect(Test::Predicates[:present?].(:name, name: 'Jane')).to be_success

      expect(Test::Predicates[:present?].(:name, {})).to be_failure
      expect(Test::Predicates[:present?].(:name, name: nil)).to be_failure
      expect(Test::Predicates[:present?].(:name, name: {})).to be_failure
      expect(Test::Predicates[:present?].(:name, name: [])).to be_failure
      expect(Test::Predicates[:present?].(:name, name: [])).to be_failure
    end
  end

  describe 'defining schema' do
    it 'works' do
      validation = Test::Validation.new

      expect(validation.(name: 'Jane')).to be_empty
      expect(validation.(name: '')).to eql(name: [validation.rules[:name]])
    end
  end
end
