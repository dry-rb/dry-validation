# frozen_string_literal: true

module Dry
  module Validation
    # A wrapper for macro validation blocks
    #
    # @api public
    class Macro
      extend Dry::Initializer

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
    end
  end
end
