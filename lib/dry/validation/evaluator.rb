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

      # Failure accumulator object
      #
      # @api public
      class Failures
        # @api private
        attr_reader :path

        # @api private
        attr_reader :opts

        # @api private
        def initialize(path = ROOT_PATH)
          @path = Dry::Schema::Path[path]
          @opts = []
        end

        # Set failure
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
        # @api public
        def failure(message, tokens = EMPTY_HASH)
          @opts << { message: message, tokens: tokens, path: path }
          self
        end
      end

      # @!attribute [r] _contract
      #   @return [Contract]
      #   @api private
      param :_contract

      # @!attribute [r] keys
      #   @return [Array<String, Symbol, Hash>]
      #   @api private
      option :keys

      # @!attribute [r] _context
      #   @return [Concurrent::Map]
      #   @api public
      option :_context

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
        instance_exec(_context, &block)
      end

      # Get failures object for the default or provided path
      #
      # @param [Symbol,String,Hash,Array<Symbol>] path
      #
      # @return [Failures]
      #
      # @see Failures#failure
      #
      # @api public
      def key(path = self.path)
        (@key ||= EMPTY_HASH.dup)[path] ||= Failures.new(path)
      end

      # Get failures object for base errors
      #
      # @return [Failures]
      #
      # @see Failures#failure
      #
      # @api public
      def base
        @base ||= Failures.new
      end

      # Return aggregated failures
      #
      # @return [Array<Hash>]
      #
      # @api private
      def failures
        failures = []
        failures += @base.opts if defined?(@base)
        failures.concat(@key.values.flat_map(&:opts)) if defined?(@key)
        failures
      end

      # @api private
      def respond_to_missing?(meth, include_private = false)
        super || _contract.respond_to?(meth, true)
      end

      private

      # Forward to the underlying contract
      #
      # @api private
      def method_missing(meth, *args, &block)
        # yes, we do want to delegate to private methods too
        if _contract.respond_to?(meth, true)
          _contract.__send__(meth, *args, &block)
        else
          super
        end
      end
    end
  end
end
