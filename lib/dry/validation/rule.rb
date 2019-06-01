# frozen_string_literal: true

require 'dry/equalizer'
require 'dry/initializer'

require 'dry/validation/constants'

module Dry
  module Validation
    # Rules capture configuration and evaluator blocks
    #
    # When a rule is applied, it creates an `Evaluator` using schema result and its
    # block will be evaluated in the context of the evaluator.
    #
    # @see Contract#rule
    #
    # @api public
    class Rule
      include Dry::Equalizer(:keys, :block, inspect: false)

      extend Dry::Initializer

      # @!attribute [r] keys
      #   @return [Array<Symbol, String, Hash>]
      #   @api private
      option :keys

      # @!attribute [r] macros
      #   @return [Array<Symbol>]
      #   @api private
      option :macros, default: proc { EMPTY_ARRAY.dup }

      # @!attribute [r] block
      #   @return [Proc]
      #   @api private
      option :block

      # Evaluate the rule within the provided context
      #
      # @param [Contract] contract
      # @param [Result] result
      #
      # @api private
      def call(contract, result)
        Evaluator.new(
          contract,
          values: result.values, keys: keys, macros: macros, _context: result.context,
          &block
        )
      end

      # Define which macros should be executed
      #
      # @see Contract#rule
      # @return [Rule]
      #
      # @api public
      def validate(*macros, &block)
        @macros = macros.map { |spec| Array(spec) }.map(&:flatten)
        @block = block if block
        self
      end

      # Return a nice string representation
      #
      # @return [String]
      #
      # @api public
      def inspect
        %(#<#{self.class} keys=#{keys.inspect}>)
      end
    end
  end
end
