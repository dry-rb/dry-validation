# frozen_string_literal: true

require 'concurrent/map'

require 'dry/equalizer'
require 'dry/initializer'

require 'dry/validation/config'
require 'dry/validation/constants'
require 'dry/validation/rule'
require 'dry/validation/evaluator'
require 'dry/validation/messages/resolver'
require 'dry/validation/result'
require 'dry/validation/contract/class_interface'

module Dry
  module Validation
    # Contract objects apply rules to input
    #
    # A contract consists of a schema and rules. The schema is applied to the
    # input before rules are applied, this way you can be sure that your rules
    # won't be applied to values that didn't pass schema checks.
    #
    # It's up to you how exactly you're going to separate schema checks from
    # your rules.
    #
    # @example
    #   class NewUser < Dry::Validation::Contract
    #     params do
    #       required(:email).filled(:string)
    #       required(:age).filled(:integer)
    #       optional(:login).maybe(:string, :filled?)
    #       optional(:password).maybe(:string, min_size?: 10)
    #       optional(:password_confirmation).maybe(:string)
    #     end
    #
    #     rule(:password) do
    #       failure('is required') if values[:login] && !values[:password]
    #     end
    #
    #     rule(:age) do
    #       failure('must be greater or equal 18') if values[:age] < 18
    #     end
    #   end
    #
    #   new_user_contract = NewUserContract.new
    #   new_user_contract.call(email: 'jane@doe.org', age: 21)
    #
    # @api public
    class Contract
      include Dry::Equalizer(:schema, :rules, :messages)

      extend Dry::Initializer
      extend ClassInterface

      config.messages.top_namespace = 'dry_validation'

      # @!attribute [r] config
      #   @return [Config]
      #   @api public
      option :config, default: -> { self.class.config }

      # @!attribute [r] locale
      #   @return [Symbol]
      #   @api public
      option :locale, default: -> { :en }

      # @!attribute [r] schema
      #   @return [Dry::Schema::Params, Dry::Schema::JSON, Dry::Schema::Processor]
      #   @api private
      option :schema, default: -> { self.class.__schema__ }

      # @!attribute [r] rules
      #   @return [Hash]
      #   @api private
      option :rules, default: -> { self.class.rules }

      # @!attribute [r] message_resolver
      #   @return [Messages::Resolver]
      #   @api private
      option :message_resolver, default: -> { Messages::Resolver.new(self.class.messages, locale) }

      # Apply contract to an input
      #
      # @return [Result]
      #
      # @api public
      def call(input)
        Result.new(schema.(input), locale: locale) do |result|
          context = Concurrent::Map.new

          rules.each do |rule|
            next if rule.keys.any? { |key| result.error?(key) }

            rule.(self, result, context).failures.each do |failure|
              result.add_error(message_resolver[failure])
            end
          end
        end
      end
    end
  end
end
