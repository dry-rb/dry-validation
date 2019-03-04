# frozen_string_literal: true

require 'dry/initializer'
require 'dry/validation/constants'

module Dry
  module Validation
    # Evaluator is the execution context for rules
    #
    # Evaluators expose an API for setting failure messages and forward
    # method calls to the contracts, so that you can use your contract
    # methods within rule blocks
    #
    # @api private
    class Evaluator
      extend Dry::Initializer

      # @!attribute [r] _context
      #   @return [Contract]
      #   @api private
      param :_context

      # @!attribute [r] keys
      #   @return [Array<String, Symbol, Hash>]
      #   @api private
      option :keys

      # @!attribute [r] default_id
      #   @return [String, Symbol, Hash]
      #   @api private
      option :default_id, default: proc { keys.first }

      # @!attribute [r] values
      #   @return [Object]
      #   @api private
      option :values

      # @!attribute [r] message
      #   @return [String]
      #   @api private
      attr_reader :message

      # Initialize a new evaluator
      #
      # @api private
      def initialize(*args, &block)
        super(*args)
        @failure = false
        instance_eval(&block)
      end

      # Set failure message
      #
      # @overload failure(message)
      #   Set message text explicitly
      #   @param message [String] The message text
      #   @example
      #     failure('this failed')
      #
      # @overload failure(id)
      #   Use message identifier (needs localized messages setup)
      #   @param id [Symbol] The message id
      #   @example
      #     failure(:taken)
      #
      # @overload failure(key, message)
      #   Set message under specified key (overrides rule's default key)
      #   @param id [Symbol] The message key
      #   @example
      #     failure(:my_error, 'this failed')
      #
      # @return [Evaluator]
      #
      # @api public
      def failure(*args, **tokens)
        id, text =
          if args.size.equal?(1)
            case (msg = args[0])
            when Symbol
              [default_id, _context.message(msg, rule: default_id, tokens: tokens)]
            when String
              [default_id, msg]
            end
          else
            args
          end
        @failure = true
        @message = [id, text]
        self
      end

      # Check if evaluation resulted in a failure message
      #
      # @return [Boolean]
      #
      # @api private
      def failure?
        @failure.equal?(true)
      end

      # @api private
      def respond_to_missing?(meth, include_private = false)
        super || _context.respond_to?(meth, true)
      end

      private

      # Forward to the underlying context
      #
      # @api private
      def method_missing(meth, *args, &block)
        # yes, we do want to delegate to private methods too
        if _context.respond_to?(meth, true)
          _context.__send__(meth, *args, &block)
        else
          super
        end
      end
    end
  end
end
