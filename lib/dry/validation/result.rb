# frozen_string_literal: true

require 'dry/equalizer'

require 'dry/validation/constants'
require 'dry/validation/error_set'

module Dry
  module Validation
    # Result objects are returned by contracts
    #
    # @api public
    class Result
      include Dry::Equalizer(:values, :errors)

      # Build a new result
      #
      # @param [Dry::Schema::Result]
      #
      # @api private
      def self.new(values)
        result = super
        yield(result) if block_given?
        result.freeze
      end

      # @!attribute [r] values
      #   @return [Dry::Schema::Result]
      #   @api private
      attr_reader :values

      # @!attribute [r] error_set
      #   @return [ErrorSet]
      #   @api public
      attr_reader :error_set

      # Initialize a new result
      #
      # @api private
      def initialize(values)
        @values = values
        @error_set = ErrorSet.new(values.message_set.to_a, failures: true)
      end

      # Return error hash
      #
      # @return [Hash<Symbol=>Array<String>>]
      #
      # @api public
      def errors
        error_set.to_h
      end
      alias_method :messages, :errors

      # Check if result is successful
      #
      # @return [Bool]
      #
      # @api public
      def success?
        error_set.empty?
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
        error_set.add(error)
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
        if values.key?(key)
          values[key]
        elsif storage.key?(key)
          storage[key]
        end
      end

      # Store value under specified key
      #
      # @param [Symbol] key
      # @param [Object] value
      #
      # @return [Object]
      #
      # @api public
      def []=(key, value)
        raise ArgumentError, "Key +#{key}+ was already set" if key?(key)

        storage[key] = value
      end

      # Check if a key was set
      #
      # @param [Symbol] key
      #
      # @return [Bool]
      #
      # @api public
      def key?(key)
        values.key?(key) || storage.key?(key)
      end

      # Coerce to a hash
      #
      # @api public
      def to_h
        values.to_h
      end
      alias_method :to_hash, :to_h

      # Return a string representation
      #
      # @api public
      def inspect
        "#<#{self.class}#{to_h.inspect} errors=#{errors.inspect}>"
      end

      # Freeze result and its error set
      #
      # @api private
      def freeze
        error_set.freeze
        super
      end

      private

      # @api private
      def storage
        @storage ||= EMPTY_HASH.dup
      end
    end
  end
end
