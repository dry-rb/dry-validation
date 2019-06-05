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

      # @api private
      def extract_block_options(options)
        block_options.map { |key, value| [key, options[value]] }.to_h
      end

      private

      # @api private
      def block_options
        @block_options ||= block
          .parameters
          .select { |arg| arg[0].equal?(:keyreq) }
          .map(&:last)
          .map { |name| [name, Rule::BLOCK_OPTIONS_MAPPINGS[name]] }
          .to_h
      end
    end
  end
end
