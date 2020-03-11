# frozen_string_literal: true

require "dry/validation/constants"
require "dry/validation/function"

module Dry
  module Validation
    # A wrapper for macro validation blocks
    #
    # @api public
    class Macro < Function
      # @!attribute [r] name
      #   @return [Symbol]
      #   @api public
      param :name

      # @!attribute [r] args
      #   @return [Array]
      #   @api public
      option :args

      # @!attribute [r] block
      #   @return [Proc]
      #   @api private
      option :block

      # @api private
      def with(args)
        self.class.new(name, args: args, block: block)
      end

      # @api private
      def extract_block_options(options)
        block_options.map { |key, value| [key, options[value]] }.to_h
      end
    end
  end
end
