# frozen_string_literal: true

require "concurrent/map"

require "dry/validation/constants"

module Dry
  module Validation
    # Result objects are returned by contracts
    #
    # @api public
    class Result
      include Dry::Equalizer(:schema_result, :context, :errors, inspect: false)

      # Build a new result
      #
      # @param [Dry::Schema::Result] schema_result
      #
      # @api private
      def self.new(schema_result, context = ::Concurrent::Map.new, options = EMPTY_HASH)
        result = super
        yield(result) if block_given?
        result.freeze
      end

      # Context that's shared between rules
      #
      # @return [Concurrent::Map]
      #
      # @api public
      attr_reader :context

      # Result from contract's schema
      #
      # @return [Dry::Schema::Result]
      #
      # @api private
      attr_reader :schema_result

      # Result options
      #
      # @return [Hash]
      #
      # @api private
      attr_reader :options

      # Initialize a new result
      #
      # @api private
      def initialize(schema_result, context, options)
        @schema_result = schema_result
        @context = context
        @options = options
        @errors = initialize_errors
      end

      # Return values wrapper with the input processed by schema
      #
      # @return [Values]
      #
      # @api public
      def values
        @values ||= Values.new(schema_result.to_h)
      end

      # Get error set
      #
      # @!macro errors-options
      #   @param [Hash] new_options
      #   @option new_options [Symbol] :locale Set locale for messages
      #   @option new_options [Boolean] :hints Enable/disable hints
      #   @option new_options [Boolean] :full Get messages that include key names
      #
      # @return [MessageSet]
      #
      # @api public
      def errors(new_options = EMPTY_HASH)
        new_options.empty? ? @errors : @errors.with(schema_errors(new_options), new_options)
      end

      # Check if result is successful
      #
      # @return [Bool]
      #
      # @api public
      def success?
        @errors.empty?
      end

      # Check if result is not successful
      #
      # @return [Bool]
      #
      # @api public
      def failure?
        !success?
      end

      # Check if values include an error for the provided key
      #
      # @api public
      def error?(key)
        errors.any? { |msg| Schema::Path[msg.path].include?(Schema::Path[key]) }
      end

      # Check if the base schema (without rules) includes an error for the provided key
      #
      # @api private
      def schema_error?(key)
        schema_result.error?(key)
      end

      # Check if the rules includes an error for the provided key
      #
      # @api private
      def rule_error?(key)
        !schema_error?(key) && error?(key)
      end

      # Check if the result contains any base rule errors
      #
      # @api private
      def base_rule_error?
        !errors.filter(:base?).empty?
      end

      # Check if there's any error for the provided key
      #
      # This does not consider errors from the nested values
      #
      # @api private
      def base_error?(key)
        schema_result.errors.any? { |error|
          key_path = Schema::Path[key]
          err_path = Schema::Path[error.path]

          next unless key_path.same_root?(err_path)

          key_path == err_path
        }
      end

      # Add a new error for the provided key
      #
      # @api private
      def add_error(error)
        @errors.add(error)
        self
      end

      # Read a value under provided key
      #
      # @param [Symbol] key
      #
      # @return [Object]
      #
      # @api public
      def [](key)
        values[key]
      end

      # Check if a key was set
      #
      # @param [Symbol] key
      #
      # @return [Bool]
      #
      # @api public
      def key?(key)
        values.key?(key)
      end

      # Coerce to a hash
      #
      # @api public
      def to_h
        values.to_h
      end

      # Return a string representation
      #
      # @api public
      def inspect
        if context.empty?
          "#<#{self.class}#{to_h} errors=#{errors.to_h}>"
        else
          "#<#{self.class}#{to_h} errors=#{errors.to_h} context=#{context.each.to_h}>"
        end
      end

      # Freeze result and its error set
      #
      # @api private
      def freeze
        values.freeze
        errors.freeze
        super
      end

      if RUBY_VERSION >= "2.7"
        # Pattern matching
        #
        # @api private
        def deconstruct_keys(keys)
          values.deconstruct_keys(keys)
        end

        # Pattern matching
        #
        # @api private
        def deconstruct
          [values, context.each.to_h]
        end
      end

      private

      # @api private
      def initialize_errors(options = self.options)
        MessageSet.new(schema_errors(options), options)
      end

      # @api private
      def schema_errors(options)
        schema_result.message_set(options).to_a
      end
    end
  end
end
