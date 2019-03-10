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

      # @!attribute [r] rule
      #   @return [Symbol] rule The rule identifier (might be the same as path)
      attr_reader :rule

      # @!attribute [r] path
      #   @return [Array<Symbol, Integer>] path The path to the value with the error
      attr_reader :path

      # Initialize a new error object
      #
      # @api private
      def initialize(text, path:, rule: nil)
        @text = text
        @path = build_path(path, [])
        @rule = rule || @path.last
        @base = path.nil?
      end

      # Check if this is a base error not associated with any key
      #
      # @return [Boolean]
      #
      # @api public
      def base?
        @base
      end

      # Dump error to a string
      #
      # @return [String]
      #
      # @api public
      def to_s
        text
      end

      private

      # @api private
      def build_path(path, acc)
        case path
        when Hash
          key, value = path.first
          build_path(value, acc << key)
        when Array
          acc.concat(path)
        else
          acc << path
        end
      end
    end
  end
end
