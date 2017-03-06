# -*- coding: utf-8 -*-
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
    before do
      module Test
        module Predicates
          include Dry::Logic::Predicates

          def self.email?(input)
            input.include?('@') # for the lols
          end
        end
      end
    end

    context 'when configured globally' do
      subject(:schema) do
        Dry::Validation.Schema(base_class) do
          required(:email) { filled? & email? }
        end
      end

      before do
        Dry::Validation::Schema.predicates(Test::Predicates)
      end

      after do
        # HACK: reset global predicates configuration
        Dry::Validation::Schema.configure do |config|
          config.predicates = Dry::Logic::Predicates
        end
      end

      include_context 'uses custom predicates'
    end

    context 'when configured locally' do
      subject(:schema) do
        Dry::Validation.Schema(base_class) do
          configure do
            predicates(Test::Predicates)
          end

          required(:email) { filled? & email? }
        end
      end

      include_context 'uses custom predicates'
    end
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
        configure do
          option :email_check

          def email?(value)
            email_check.(value)
          end
        end

        required(:email).filled(:email?)
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

      required(:email).filled(:email?)
    end

    expect { schema.(email: 'foo').messages }.to raise_error(
      Dry::Validation::MissingMessageError, /email/
    )
  end

  it 'works with custom predicate args' do
    schema = Dry::Validation.Schema do
      configure do
        def self.messages
          Dry::Validation::Messages.default.merge(
            en: { errors: { fav_number?: 'must be %{expected}' } }
          )
        end
        def fav_number?(expected, current)
          current == expected
        end
      end

      required(:foo) { fav_number?(23) }
    end

    expect(schema.(foo: 20).messages).to eql(
      foo: ['must be 23']
    )

  end

  it 'works when no predicate args' do
    schema = Dry::Validation.Schema do
      configure do
        def self.messages
          Dry::Validation::Messages.default.merge(
            en: { errors: { with_no_args?: 'is always false' } }
          )
        end

        def with_no_args?
          false
        end
      end

      required(:email).filled(:with_no_args?)
    end

    expect(schema.(email: 'foo').messages).to eql(
      email: ['is always false']
    )
  end

  it 'works with nested schemas' do
    schema = Dry::Validation.Schema do
      configure do
        def ok?(_value)
          true
        end
      end

      required(:foo).schema do
        required(:bar).value(:ok?)
      end
    end

    expect(schema.(foo: { bar: "1" })).to be_success
  end

  it 'works with interpolation of messages' do
    schema = Dry::Validation.Schema do
      configure do
        option :categories, []

        def self.messages
          Dry::Validation::Messages.default.merge(
            en: {
              errors: {
                valid_category?: 'must be one of the categories: %{categories}'
              }
            },
            pl: {
              errors: {
                valid_category?: 'musi być jedną z: %{categories}'
              }
            }
          )
        end

        def valid_category?(categories, value)
          categories.include?(value)
        end
      end

      required(:category).filled(valid_category?: categories)
    end.with(categories: %w(foo bar))

    expect(schema.(category: 'baz').messages).to eql(
      category: ['must be one of the categories: foo, bar']
    )

    expect(schema.(category: 'baz').messages(locale: :pl)).to eql(
      category: ['musi być jedną z: foo, bar']
    )
  end
end
