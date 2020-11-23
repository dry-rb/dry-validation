# frozen_string_literal: true

require "concurrent/map"

require "dry/equalizer"
require "dry/initializer"
require "dry/schema/path"

require "dry/validation/config"
require "dry/validation/constants"
require "dry/validation/rule"
require "dry/validation/evaluator"
require "dry/validation/messages/resolver"
require "dry/validation/result"
require "dry/validation/contract/class_interface"

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

      config.messages.top_namespace = DEFAULT_ERRORS_NAMESPACE
      config.messages.load_paths << DEFAULT_ERRORS_PATH

      # @!attribute [r] config
      #   @return [Config] Contract's configuration object
      #   @api public
      option :config, default: -> { self.class.config }

      # @!attribute [r] macros
      #   @return [Macros::Container] Configured macros
      #   @see Macros::Container#register
      #   @api public
      option :macros, default: -> { config.macros }

      # @!attribute [r] default_context
      #   @return [Hash] Default context for rules
      #   @api public
      option :default_context, default: -> { EMPTY_HASH }

      # @!attribute [r] schema
      #   @return [Dry::Schema::Params, Dry::Schema::JSON, Dry::Schema::Processor]
      #   @api private
      option :schema, default: -> { self.class.__schema__ || raise(SchemaMissingError, self.class) }

      # @!attribute [r] rules
      #   @return [Hash]
      #   @api private
      option :rules, default: -> { self.class.rules }

      # @!attribute [r] message_resolver
      #   @return [Messages::Resolver]
      #   @api private
      option :message_resolver, default: -> { Messages::Resolver.new(messages) }

      # Apply the contract to an input
      #
      # @param [Hash] input The input to validate
      # @param [Hash] context Initial context for rules
      #
      # @return [Result]
      #
      # @api public
      def call(input, context = EMPTY_HASH)
        context_map = Concurrent::Map.new.tap do |map|
          default_context.each { |key, value| map[key] = value }
          context.each { |key, value| map[key] = value }
        end

        Result.new(schema.(input), context_map) do |result|
          rules.each do |rule|
            next if rule.keys.any? { |key| error?(result, key) }

            rule_result = rule.(self, result)

            rule_result.failures.each do |failure|
              result.add_error(message_resolver.(**failure))
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
      def error?(result, spec)
        path = Schema::Path[spec]

        if path.multi_value?
          return path.expand.any? { |nested_path| error?(result, nested_path) }
        end

        return true if result.schema_error?(path)

        path
          .to_a[0..-2]
          .any? { |key|
            curr_path = Schema::Path[path.keys[0..path.keys.index(key)]]

            return false unless result.schema_error?(curr_path)

            result.errors.any? { |err|
              (other = Schema::Path[err.path]).same_root?(curr_path) && other == curr_path
            }
          }
      end

      # Get a registered macro
      #
      # @return [Proc,#to_proc]
      #
      # @api private
      def macro(name, *args)
        (macros.key?(name) ? macros[name] : Macros[name]).with(args)
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
