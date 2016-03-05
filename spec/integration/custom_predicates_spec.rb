RSpec.describe Dry::Validation do
  subject(:validation) { schema.new }

  shared_context 'uses custom predicates' do
    it 'uses provided custom predicates' do
      expect(validation.(email: 'jane@doe')).to be_success

      expect(validation.(email: nil).messages).to eql(
        email: ['email must be filled', 'must be a valid email']
      )

      expect(validation.(email: 'jane').messages).to eql(
        email: ['must be a valid email']
      )
    end
  end

  describe 'defining schema with custom predicates container' do
    let(:schema) do
      Class.new(Dry::Validation::Schema) do
        configure do |config|
          config.predicates = Test::Predicates
        end

        def self.messages
          Dry::Validation::Messages.default.merge(
            en: { errors: { email?: 'must be a valid email' } }
          )
        end

        key(:email) { filled? & email? }
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
        key(:email) { filled? & email? }

        def self.messages
          Dry::Validation::Messages.default.merge(
            en: { errors: { email?: 'must be a valid email' } }
          )
        end

        def email?(value)
          value.include?('@')
        end
      end
    end

    include_context 'uses custom predicates'
  end
end
