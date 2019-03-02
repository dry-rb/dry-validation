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

      # @!attribute [r] context
      #   @return [Contract]
      #   @api private
      param :context

      # @!attribute [r] name
      #   @return [Symbol]
      #   @api private
      option :name

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
      # @example using a message string
      #   failure("this is not valid")
      #
      # @example using a message identifier
      #   failure(:invalid) # needs a corresponding message translation
      #
      # @param [Symbol, String] msg_or_key The message or its identifier
      #
      # @return [Evaluator]
      #
      # @api public
      def failure(msg_or_key, **tokens)
        @message =
          case msg_or_key
          when Symbol
            context.message(msg_or_key, rule: name, tokens: tokens)
          when String
            msg_or_key
          end
        @failure = true
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
        super || context.respond_to?(meth, true)
      end

      private

      # Forward to the underlying context
      #
      # @api private
      def method_missing(meth, *args, &block)
        # yes, we do want to delegate to private methods too
        if context.respond_to?(meth, true)
          context.__send__(meth, *args, &block)
        else
          super
        end
      end
    end
  end
end
