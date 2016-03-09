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

  let(:base_class) do
    Class.new(Dry::Validation::Schema) do
      def self.messages
        Dry::Validation::Messages.default.merge(
          en: { errors: { email?: 'must be a valid email' } }
        )
      end
    end
  end

  describe 'defining schema with custom predicates container' do
    subject(:schema) do
      Dry::Validation.Schema(type: base_class) do
        configure do
          config.predicates = Test::Predicates
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
      Dry::Validation.Schema(type: base_class) do
        configure do
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
