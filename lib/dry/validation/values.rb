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
        return data.dig(*args) if args.size > 1

        case (key = args[0])
        when Symbol, String, Array, Hash
          path = Schema::Path[key]
          keys = path.to_a

          return data.dig(*keys) unless keys.last.is_a?(Array)

          last = keys.pop
          vals = self.class.new(data.dig(*keys))

          last.map { |name| vals[name] }
        else
          raise ArgumentError, '+key+ must be a valid path specification'
        end
      end

      # @api public
      def key?(key, hash = data)
        return hash.key?(key) if key.is_a?(Symbol)

        Schema::Path[key].reduce(hash) do |a, e|
          if e.is_a?(Array)
            result = e.all? { |k| key?(k, a) }
            return result
          else
            return false unless a.is_a?(Array) ? (0..a.size - 1).cover?(e) : a.key?(e)
          end
          a[e]
        end

        true
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
