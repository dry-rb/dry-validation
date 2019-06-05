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

      # Mapping for block kwarg options used by block_options
      #
      # @see Rule#block_options
      BLOCK_OPTIONS_MAPPINGS = Hash.new { |_, key| key }.update(context: :_context).freeze

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
          keys: keys,
          macros: macros,
          block_options: block_options,
          result: result,
          values: result.values,
          _context: result.context,
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

      # Define a validation function for each element of an array
      #
      # The function will be applied only if schema checks passed
      # for a given array item.
      #
      # @example
      #   rule(:nums).each do
      #     key.failure("must be greater than 0") if value < 0
      #   end
      #
      # @return [Rule]
      #
      # @api public
      def each(&block)
        root = keys
        @keys = []

        @block = proc do
          values[root].each_with_index do |_, idx|
            path = [*root, idx]

            next if result.error?(path)

            evaluator = with(keys: [path], &block)

            failures.concat(evaluator.failures)
          end
        end

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

      # Extract options for the block kwargs
      #
      # @return [Hash]
      #
      # @api private
      def block_options
        return EMPTY_HASH unless block

        @block_options ||= block
          .parameters
          .select { |arg| arg[0].equal?(:keyreq) }
          .map(&:last)
          .map { |name| [name, BLOCK_OPTIONS_MAPPINGS[name]] }
          .to_h
      end
    end
  end
end
