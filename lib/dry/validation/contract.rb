# frozen_string_literal: true

require 'dry/equalizer'
require 'dry/configurable'
require 'dry/initializer'

require 'dry/validation/constants'
require 'dry/validation/rule'
require 'dry/validation/evaluator'
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

      extend Dry::Configurable
      extend Dry::Initializer
      extend ClassInterface

      # @!group Configuration

      # @overload config.messages=(identifier)
      #   Set message backend
      #
      #   @param identifier [Symbol] the backend identifier, either `:yaml` or `:i18n`
      #
      #   @api public
      # @!scope class
      setting :messages, :yaml

      # @overload config.messages_file=(path)
      #   Set additional path to messages file
      #
      #   @param path [String, Pathname] the path
      #
      #   @api public
      # @!scope class
      setting :messages_file

      # @overload config.namespace=(name)
      #   Set namespace that will be used to override default messages
      #
      #   @param name [Symbol] the namespace
      #
      #   @api public
      # @!scope class
      setting :namespace

      # @!endgroup

      # @!attribute [r] schema
      #   @return [Dry::Schema::Params, Dry::Schema::JSON, Dry::Schema::Processor]
      #   @api private
      option :schema, default: -> { self.class.__schema__ }

      # @!attribute [r] rules
      #   @return [Hash]
      #   @api private
      option :rules, default: -> { self.class.rules }

      # @!attribute [r] messages
      #   @return [Messages::I18n, Messages::YAML]
      #   @api private
      option :messages, default: -> { self.class.messages }

      # Apply contract to an input
      #
      # @return [Result]
      #
      # @api public
      def call(input)
        Result.new(schema.(input)) do |result|
          rules.each do |rule|
            next if rule.keys.any? { |key| result.error?(key) }

            rule_result = rule.(self, result)
            result.add_error(*rule_result.message) if rule_result.failure?
          end
        end
      end

      # Get message text for the given rule name and options
      #
      # @return [String]
      #
      # @api private
      def message(key, tokens: EMPTY_HASH, **opts)
        template = messages[key, opts.merge(tokens)]

        if template
          template.(template.data(tokens))
        else
          raise MissingMessageError, "Message template for #{key.inspect} was not found"
        end
      end
    end
  end
end
