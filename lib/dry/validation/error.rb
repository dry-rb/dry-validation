# frozen_string_literal: true

require 'dry/equalizer'
require 'dry/schema/message'

module Dry
  module Validation
    # Error message
    #
    # @api public
    class Error < Schema::Message
      include Dry::Equalizer(:error, :path)

      # @!attribute [r] error
      #   @return [Object] error The error object. Usually a string but can be an arbitrary value
      attr_reader :error

      # @!attribute [r] path
      #   @return [Array<Symbol, Integer>] path The path to the value with the error
      attr_reader :path

      # @api public
      class Localized < Error
        # @api public
        def evaluate(**opts)
          Error.new(error.(opts), path: path)
        end
      end

      # Build an error
      #
      # @return [Error, Error::Localized]
      #
      # @api public
      def self.[](error, path)
        error.respond_to?(:call) ? Localized.new(error, path: path) : Error.new(error, path: path)
      end

      # Initialize a new error object
      #
      # @api private
      def initialize(error, path:)
        @error = error
        @path = Array(path)
      end

      # Check if this is a base error not associated with any key
      #
      # @return [Boolean]
      #
      # @api public
      def base?
        @base ||= path.compact.empty?
      end

      # Returns error message or object
      #
      # @return [String, Object]
      #
      # @api public
      def dump
        error
      end
    end
  end
end
