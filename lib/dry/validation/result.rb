# frozen_string_literal: true

require 'concurrent/map'
require 'dry/equalizer'

require 'dry/validation/constants'
require 'dry/validation/message_set'

module Dry
  module Validation
    # Result objects are returned by contracts
    #
    # @api public
    class Result
      include Dry::Equalizer(:values, :context, :errors)

      # Build a new result
      #
      # @param [Dry::Schema::Result]
      #
      # @api private
      def self.new(values, context = ::Concurrent::Map.new, options = EMPTY_HASH)
        result = super
        yield(result) if block_given?
        result.freeze
      end

      # @!attribute [r] values
      #   @return [Dry::Schema::Result]
      #   @api private
      attr_reader :values

      # @!attribute [r] context
      #   @return [Concurrent::Map]
      #   @api public
      attr_reader :context

      # @!attribute [r] options
      #   @return [Hash]
      #   @api private
      attr_reader :options

      # Initialize a new result
      #
      # @api private
      def initialize(values, context, options)
        @values = values
        @context = context
        @options = options
        @errors = initialize_errors
      end

      # Get error set
      #
      # @return [MessageSet]
      #
      # @api public
      def errors(new_options = EMPTY_HASH)
        new_options.empty? ? @errors : @errors.with(schema_errors(new_options), new_options)
      end
      alias_method :messages, :errors

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
        values.error?(key)
      end

      # Add a new error for the provided key
      #
      # @api private
      def add_error(error)
        errors.add(error)
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
        values.message_set(options).to_a
      end
    end
  end
end
