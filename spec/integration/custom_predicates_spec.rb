RSpec.describe Dry::Validation do
  subject(:validation) { schema.new }

  shared_context 'uses custom predicates' do
    it 'uses provided custom predicates' do
      expect(validation.(email: 'jane@doe')).to be_empty

      expect(validation.(email: nil)).to match_array([
        [:error, [:input, [:email, nil, [[:val, [:email, [:predicate, [:filled?, []]]]]]]]]
      ])

      expect(validation.(email: 'jane')).to match_array([
        [:error, [:input, [:email, 'jane', [[:val, [:email, [:predicate, [:email?, []]]]]]]]]
      ])
    end
  end

  describe 'defining schema with custom predicates container' do
    let(:schema) do
      Class.new(Dry::Validation::Schema) do
        configure do |config|
          config.predicates = Test::Predicates
        end

        key(:email) { |value| value.filled? & value.email? }
      end
    end

    before do
      module Test
        module Predicates
          include Dry::Logic::Predicates

          predicate(:email?) do |input|
            input.include?('@') # for the lols
          end
        end
      end
    end

    include_context 'uses custom predicates'
  end

  describe 'defining schema with custom predicate methods' do
    let(:schema) do
      Class.new(Dry::Validation::Schema) do
        key(:email) { |value| value.filled? & value.email? }

        def email?(value)
          value.include?('@')
        end
      end
    end

    include_context 'uses custom predicates'
  end
end
