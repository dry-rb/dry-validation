# frozen_string_literal: true

require 'dry/equalizer'

require 'dry/schema/constants'
require 'dry/schema/message'

module Dry
  module Validation
    # Message message
    #
    # @api public
    class Message < Schema::Message
      include Dry::Equalizer(:text, :path, :meta)

      # @!attribute [r] text
      #   @return [String] text The error message text
      attr_reader :text

      # @!attribute [r] path
      #   @return [Array<Symbol, Integer>] path The path to the value with the error
      attr_reader :path

      # @!attribute [r] meta
      #   @return [Hash] meta Optional hash with meta-data
      attr_reader :meta

      # @api public
      class Localized < Message
        # @api public
        def evaluate(**opts)
          evaluated_text, rest = text.(opts)
          Message.new(evaluated_text, path: path, meta: rest.merge(meta))
        end
      end

      # Build an error
      #
      # @return [Message, Message::Localized]
      #
      # @api public
      def self.[](text, path, meta)
        klass = text.respond_to?(:call) ? Localized : Message
        klass.new(text, path: path, meta: meta)
      end

      # Initialize a new error object
      #
      # @api private
      def initialize(text, path:, meta: EMPTY_HASH)
        @text = text
        @path = Array(path)
        @meta = meta
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
