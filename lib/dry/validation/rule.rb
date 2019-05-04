# frozen_string_literal: true

require 'dry/equalizer'
require 'dry/initializer'

module Dry
  module Validation
    # Rules are created by contracts
    #
    # @api private
    class Rule
      include Dry::Equalizer(:keys, :block, inspect: false)

      extend Dry::Initializer

      # @!atrribute [r] keys
      #   @return [Array<Symbol, String, Hash>]
      #   @api private
      option :keys

      # @!atrribute [r] block
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
          values: result.values, keys: keys, _context: result.context,
          &block
        )
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
