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

      ROOT_PATH = [nil].freeze

      # @api private
      class Failures
        # @api private
        attr_reader :path

        # @api private
        attr_reader :opts

        # @api private
        def initialize(path = ROOT_PATH)
          @path = path
          @opts = []
        end

        # @api private
        def failure(*args, **tokens)
          @opts << { args: args, tokens: tokens, path: path }
          self
        end
      end

      # @!attribute [r] _context
      #   @return [Contract]
      #   @api private
      param :_context

      # @!attribute [r] keys
      #   @return [Array<String, Symbol, Hash>]
      #   @api private
      option :keys

      # @!attribute [r] path
      #   @return [Dry::Schema::Path]
      #   @api private
      option :path, default: proc { Dry::Schema::Path[(key = keys.first) ? key : ROOT_PATH] }

      # @!attribute [r] values
      #   @return [Object]
      #   @api private
      option :values

      # Initialize a new evaluator
      #
      # @api private
      def initialize(*args, &block)
        super(*args)
        instance_eval(&block)
      end

      # Key message failures
      #
      # @api public
      def key
        @key ||= Failures.new(path)
      end

      # Base message failures
      #
      # @api public
      def base
        @base ||= Failures.new
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
        key.failure(*args, **tokens)
        self
      end

      # Return aggregated failures
      #
      # @return [Array<Hash>]
      #
      # @api private
      def failures
        failures = []
        failures += base.opts if defined?(@base)
        failures += key.opts if defined?(@key)
        failures
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
