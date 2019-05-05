# frozen_string_literal: true

require 'dry/equalizer'

module Dry
  module Validation
    # A convenient wrapper for data processed by schemas
    #
    # Values are available within the rule blocks. They act as hash-like
    # objects and expose a convenient API for accessing data.
    #
    # @api public
    class Values
      include Enumerable
      include Dry::Equalizer(:data)

      # Schema's result output
      #
      # @return [Hash]
      #
      # @api private
      attr_reader :data

      # @api private
      def initialize(data)
        @data = data
      end

      # @api public
      def [](key)
        data[key]
      end

      # @api private
      def respond_to_missing?(meth, include_private = false)
        super || data.respond_to?(meth, include_private)
      end

      private

      # @api private
      def method_missing(meth, *args, &block)
        if data.respond_to?(meth)
          data.public_send(meth, *args, &block)
        else
          super
        end
      end
    end
  end
end
