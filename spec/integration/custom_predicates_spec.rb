RSpec.describe Dry::Validation do
  shared_context 'uses custom predicates' do
    it 'uses provided custom predicates' do
      expect(schema.(email: 'jane@doe')).to be_success

      expect(schema.(email: nil).messages).to eql(
        email: ['must be filled', 'must be a valid email']
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
      Dry::Validation.Schema(base_class) do
        configure do
          config.predicates = Test::Predicates
        end

        required(:email) { filled? & email? }
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
      Dry::Validation.Schema(base_class) do
        configure do
          def email?(value)
            value.include?('@')
          end
        end

        required(:email) { filled? & email? }
      end
    end

    include_context 'uses custom predicates'
  end

  describe 'custom predicate which requires an arbitrary dependency' do
    subject(:schema) do
      Dry::Validation.Schema(base_class) do
        required(:email).required(:email?)

        configure do
          option :email_check

          def email?(value)
            email_check.(value)
          end
        end
      end
    end

    it 'uses injected dependency for the custom predicate' do
      email_check = -> input { input.include?('@') }

      expect(schema.with(email_check: email_check).(email: 'foo').messages).to eql(
        email: ['must be a valid email']
      )
    end
  end

  it 'raises an error when message is missing' do
    schema = Dry::Validation.Schema do
      configure do
        def email?(value)
          false
        end
      end

      required(:email).required(:email?)
    end

    expect { schema.(email: 'foo').messages }.to raise_error(
      Dry::Validation::MissingMessageError, /email/
    )
  end
end
