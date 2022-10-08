# frozen_string_literal: true

require "dry/initializer"
require "dry/validation/constants"

module Dry
  module Validation
    # Evaluator is the execution context for rules
    #
    # Evaluators expose an API for setting failure messages and forward
    # method calls to the contracts, so that you can use your contract
    # methods within rule blocks
    #
    # @api public
    class Evaluator
      extend Dry::Initializer
      extend Dry::Core::Deprecations[:"dry-validation"]

      deprecate :error?, :schema_error?

      # @!attribute [r] _contract
      #   @return [Contract]
      #   @api private
      param :_contract

      # @!attribute [r] result
      #   @return [Result]
      #   @api private
      option :result

      # @!attribute [r] keys
      #   @return [Array<String, Symbol, Hash>]
      #   @api private
      option :keys

      # @!attribute [r] macros
      #   @return [Array<Symbol>]
      #   @api private
      option :macros, optional: true, default: proc { EMPTY_ARRAY.dup }

      # @!attribute [r] _context
      #   @return [Concurrent::Map]
      #   @api private
      option :_context

      # @!attribute [r] path
      #   @return [Dry::Schema::Path]
      #   @api private
      option :path, default: proc { Dry::Schema::Path[(key = keys.first) ? key : ROOT_PATH] }

      # @!attribute [r] values
      #   @return [Object]
      #   @api private
      option :values

      # @!attribute [r] block_options
      #   @return [Hash<Symbol=>Symbol>]
      #   @api private
      option :block_options, default: proc { EMPTY_HASH }

      # @return [Hash]
      attr_reader :_options

      # Initialize a new evaluator
      #
      # @api private
      def initialize(contract, **options, &block)
        super(contract, **options)

        @_options = options

        if block
          exec_opts = block_options.transform_values { _options[_1] }
          instance_exec(**exec_opts, &block)
        end

        macros.each do |args|
          macro = macro(*args.flatten(1))
          instance_exec(**macro.extract_block_options(_options.merge(macro: macro)), &macro.block)
        end
      end

      # Get `Failures` object for the default or provided path
      #
      # @param [Symbol,String,Hash,Array<Symbol>] path
      #
      # @return [Failures]
      #
      # @see Failures#failure
      #
      # @api public
      def key(path = self.path)
        (@key ||= EMPTY_HASH.dup)[path] ||= Failures.new(path)
      end

      # Get `Failures` object for base errors
      #
      # @return [Failures]
      #
      # @see Failures#failure
      #
      # @api public
      def base
        @base ||= Failures.new
      end

      # Return aggregated failures
      #
      # @return [Array<Hash>]
      #
      # @api private
      def failures
        @failures ||= []
        @failures += @base.opts if defined?(@base)
        @failures.concat(@key.values.flat_map(&:opts)) if defined?(@key)
        @failures
      end

      # @api private
      def with(new_opts, &block)
        self.class.new(_contract, **_options, **new_opts, &block)
      end

      # Return default (first) key name
      #
      # @return [Symbol]
      #
      # @api public
      def key_name
        @key_name ||= keys.first
      end

      # Return the value found under the first specified key
      #
      # This is a convenient method that can be used in all the common cases
      # where a rule depends on just one key and you want a quick access to
      # the value
      #
      # @example
      #   rule(:age) do
      #     key.failure(:invalid) if value < 18
      #   end
      #
      # @return [Object]
      #
      # @api public
      def value
        values[key_name]
      end

      # Return if the value under the default key is available
      #
      # This is useful when dealing with rules for optional keys
      #
      # @example use the default key name
      #   rule(:age) do
      #     key.failure(:invalid) if key? && value < 18
      #   end
      #
      # @example specify the key name
      #   rule(:start_date, :end_date) do
      #     if key?(:start_date) && !key?(:end_date)
      #       key(:end_date).failure("must provide an end_date with start_date")
      #     end
      #   end
      #
      # @return [Boolean]
      #
      # @api public
      def key?(name = key_name)
        values.key?(name)
      end

      # Check if there are any errors on the schema under the provided path
      #
      # @param path [Symbol, String, Array] A Path-compatible spec
      #
      # @return [Boolean]
      #
      # @api public
      def schema_error?(path)
        result.schema_error?(path)
      end

      # Check if there are any errors on the current rule
      #
      # @param path [Symbol, String, Array] A Path-compatible spec
      #
      # @return [Boolean]
      #
      # @api public
      def rule_error?(path = nil)
        if path.nil?
          !key(self.path).empty?
        else
          result.rule_error?(path)
        end
      end

      # Check if there are any base rule errors
      #
      # @return [Boolean]
      #
      # @api public
      def base_rule_error?
        !base.empty? || result.base_rule_error?
      end

      # @api private
      def respond_to_missing?(meth, include_private = false)
        super || _contract.respond_to?(meth, true)
      end

      private

      # Forward to the underlying contract
      #
      # @api private
      def method_missing(meth, *args, &block)
        # yes, we do want to delegate to private methods too
        if _contract.respond_to?(meth, true)
          _contract.__send__(meth, *args, &block)
        else
          super
        end
      end
      ruby2_keywords(:method_missing) if respond_to?(:ruby2_keywords, true)
    end
  end
end
