# frozen_string_literal: true

require "dry/initializer"
require "dry/validation/constants"

module Dry
  module Validation
    # Abstract class for handling rule blocks
    #
    # @see Rule
    # @see Macro
    #
    # @api private
    class Function
      extend Dry::Initializer

      # @!attribute [r] block
      #   @return [Proc]
      #   @api private
      option :block

      # @!attribute [r] block_options
      #   @return [Hash]
      #   @api private
      option :block_options, default: -> { block ? map_keywords(block) : EMPTY_HASH }

      private

      # Extract options for the block kwargs
      #
      # @param [Proc] block Callable
      # @return Hash
      #
      # @api private
      def map_keywords(block)
        block
          .parameters
          .select { |arg,| arg.equal?(:keyreq) }
          .to_h { [_2, BLOCK_OPTIONS_MAPPINGS[_2]] }
      end
    end
  end
end
