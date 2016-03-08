RSpec.describe Dry::Validation do
  shared_context 'uses custom predicates' do
    it 'uses provided custom predicates' do
      expect(schema.(email: 'jane@doe')).to be_success

      expect(schema.(email: nil).messages).to eql(
        email: ['email must be filled', 'must be a valid email']
      )

      expect(schema.(email: 'jane').messages).to eql(
        email: ['must be a valid email']
      )
    end
  end

  describe 'defining schema with custom predicates container' do
    subject(:schema) do
      Dry::Validation.Schema do
        configure do
          configure do |config|
            config.predicates = Test::Predicates
          end

          def self.messages
            Dry::Validation::Messages.default.merge(
              en: { errors: { email?: 'must be a valid email' } }
            )
          end
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
    subject(:schema) do
      Dry::Validation.Schema do
        configure do
          def self.messages
            Dry::Validation::Messages.default.merge(
              en: { errors: { email?: 'must be a valid email' } }
            )
          end

          def email?(value)
            value.include?('@')
          end
        end

        key(:email) { filled? & email? }
      end
    end

    include_context 'uses custom predicates'
  end
end
