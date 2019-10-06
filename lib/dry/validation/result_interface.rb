# frozen_string_literal: true

module Dry
  module Validation
    # Result interface for objects returned by Contract#call
    #
    # Implementors must define #values and #errors
    module ResultInterface
      # The values of this result
      #
      # @return [Values]
      #
      # @api public
      def values
        raise NotImplementedError, "implement #values to return #{Values}"
      end

      # The errors of this result
      #
      # @return [MessageSet]
      #
      # @api public
      def errors
        raise NotImplementedError, "implement #errors to return #{MessageSet}"
      end

      # Check if result is successful
      #
      # @return [Bool]
      #
      # @api public
      def success?
        errors.empty?
      end

      # Check if result is not successful
      #
      # @return [Bool]
      #
      # @api public
      def failure?
        !success?
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
    end
  end
end
