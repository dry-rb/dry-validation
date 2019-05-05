# frozen_string_literal: true

require 'concurrent/map'
require 'dry/equalizer'

require 'dry/validation/constants'
require 'dry/validation/message_set'
require 'dry/validation/values'

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

      # @!attribute [r] context
      #   @return [Concurrent::Map]
      #   @api public
      attr_reader :context

      # @!attribute [r] schema_result
      #   @return [Dry::Schema::Result]
      #   @api private
      attr_reader :schema_result

      # @!attribute [r] options
      #   @return [Hash]
      #   @api private
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
      # @param [Hash] new_options
      # @option new_options [Symbol] :locale Set locale for messages
      # @option new_options [Boolean] :hints Enable/disable hints
      # @option new_options [Boolean] :full Get messages that include key names
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
      # @api private
      def error?(key)
        schema_result.error?(key)
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
          "#<#{self.class}#{to_h.inspect} errors=#{errors.to_h.inspect}>"
        else
          "#<#{self.class}#{to_h.inspect} errors=#{errors.to_h.inspect} context=#{context.each.to_h.inspect}>"
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
