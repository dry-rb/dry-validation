# frozen_string_literal: true

require 'dry/initializer'
require 'dry/validation/constants'

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

      private

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
