# frozen_string_literal: true

require 'concurrent/map'

require 'dry/equalizer'
require 'dry/initializer'
require 'dry/schema/path'

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
    #   class NewUserContract < Dry::Validation::Contract
    #     params do
    #       required(:email).filled(:string)
    #       required(:age).filled(:integer)
    #       optional(:login).maybe(:string, :filled?)
    #       optional(:password).maybe(:string, min_size?: 10)
    #       optional(:password_confirmation).maybe(:string)
    #     end
    #
    #     rule(:password) do
    #       key.failure('is required') if values[:login] && !values[:password]
    #     end
    #
    #     rule(:age) do
    #       key.failure('must be greater or equal 18') if values[:age] < 18
    #     end
    #   end
    #
    #   new_user_contract = NewUserContract.new
    #   new_user_contract.call(email: 'jane@doe.org', age: 21)
    #
    # @api public
    class Contract
      include Dry::Equalizer(:schema, :rules, :messages, inspect: false)

      extend Dry::Initializer
      extend ClassInterface

      config.messages.top_namespace = 'dry_validation'
      config.messages.load_paths << Pathname(__FILE__).join('../../../../config/errors.yml').realpath

      # @!attribute [r] config
      #   @return [Config] Contract's configuration object
      #   @api public
      option :config, default: -> { self.class.config }

      # @!attribute [r] locale
      #   @return [Symbol] Contract's locale (default is `:en`)
      #   @api public
      option :locale, default: -> { resolve_locale }

      # @!attribute [r] macros
      #   @return [Macros::Container] Configured macros
      #   @see Macros::Container#register
      #   @api public
      option :macros, default: -> { config.macros }

      # @!attribute [r] schema
      #   @return [Dry::Schema::Params, Dry::Schema::JSON, Dry::Schema::Processor]
      #   @api private
      option :schema, default: -> { self.class.__schema__ or raise(SchemaMissingError, self.class) }

      # @!attribute [r] rules
      #   @return [Hash]
      #   @api private
      option :rules, default: -> { self.class.rules }

      # @!attribute [r] message_resolver
      #   @return [Messages::Resolver]
      #   @api private
      option :message_resolver, default: -> { Messages::Resolver.new(messages, locale) }

      # Apply the contract to an input
      #
      # @param [Hash] input The input to validate
      #
      # @return [Result]
      #
      # @api public
      def call(input)
        Result.new(schema.(input), Concurrent::Map.new, locale: locale) do |result|
          rules.each do |rule|
            next if rule.keys.any? { |key| error?(result, key) }

            rule.(self, result).failures.each do |failure|
              result.add_error(message_resolver[failure])
            end
          end
        end
      end

      # Return a nice string representation
      #
      # @return [String]
      #
      # @api public
      def inspect
        %(#<#{self.class} schema=#{schema.inspect} rules=#{rules.inspect}>)
      end

      private

      # @api private
      def error?(result, key)
        path = Schema::Path[key]
        result.error?(path) || path.map.with_index { |k, i| result.error?(path.keys[0..i-2]) }.any?
      end

      # Get a registered macro
      #
      # @return [Proc,#to_proc]
      #
      # @api private
      def macro(name)
        macros.key?(name) ? macros[name] : Macros[name]
      end

      # Return configured locale
      #
      # @return [Symbol]
      #
      # @api private
      def resolve_locale
        if messages.default_locale.equal?(config.locale)
          config.locale
        else
          messages.default_locale
        end
      end

      # Return configured messages backend
      #
      # @return [Dry::Schema::Messages::YAML, Dry::Schema::Messages::I18n]
      #
      # @api private
      def messages
        self.class.messages
      end
    end
  end
end
