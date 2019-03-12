# frozen_string_literal: true

require 'dry/equalizer'
require 'dry/schema/message'

module Dry
  module Validation
    # Error message
    #
    # @api public
    class Error < Schema::Message
      include Dry::Equalizer(:text, :path)

      # @!attribute [r] text
      #   @return [String] text The error message text
      attr_reader :text

      # @!attribute [r] path
      #   @return [Array<Symbol, Integer>] path The path to the value with the error
      attr_reader :path

      # @api public
      class Localized < Error
        # @api public
        def evaluate(locale)
          Error.new(text.(locale), path: path)
        end
      end

      # Build an error
      #
      # @return [Error, Error::Localized]
      #
      # @api public
      def self.[](text, path)
        text.respond_to?(:call) ? Localized.new(text, path: path) : Error.new(text, path: path)
      end

      # Initialize a new error object
      #
      # @api private
      def initialize(text, path:)
        @text = text
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

      # Dump error to a string
      #
      # @return [String]
      #
      # @api public
      def to_s
        text
      end
    end
  end
end
