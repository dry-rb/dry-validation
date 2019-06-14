# frozen_string_literal: true

require 'dry/equalizer'
require 'dry/schema/path'
require 'dry/validation/constants'

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

      # Read from the provided key
      #
      # @example
      #   rule(:age) do
      #     key.failure('must be > 18') if values[:age] <= 18
      #   end
      #
      # @param [Symbol] key
      #
      # @return [Object]
      #
      # @api public
      def [](*args)
        if args.size.equal?(1)
          case (key = args[0])
          when Symbol then data[key]
          when String then self[*key.split(DOT).map(&:to_sym)]
          when Array then self[*key]
          when Hash then self[*Schema::Path[*args].to_a]
          else
            raise ArgumentError, '+key+ must be a valid path specification'
          end
        else
          data.dig(*args)
        end
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
