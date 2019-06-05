# frozen_string_literal: true

require 'dry/schema/path'
require 'dry/validation/constants'

module Dry
  module Validation
    # Failure accumulator object
    #
    # @api public
    class Failures
      # The path for messages accumulated by failures object
      #
      # @return [Dry::Schema::Path]
      #
      # @api private
      attr_reader :path

      # Options for messages
      #
      # These options are used by MessageResolver
      #
      # @return [Hash]
      #
      # @api private
      attr_reader :opts

      # @api private
      def initialize(path = ROOT_PATH)
        @path = Dry::Schema::Path[path]
        @opts = EMPTY_ARRAY.dup
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
      # @see Evaluator#key
      # @see Evaluator#base
      #
      # @api public
      def failure(message, tokens = EMPTY_HASH)
        opts << { message: message, tokens: tokens, path: path }
        self
      end
    end
  end
end
