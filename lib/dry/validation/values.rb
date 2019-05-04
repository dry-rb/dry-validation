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

      # @!attribute [r] data
      #   Schema's result output
      #   @return [Hash]
      #   @api private
      attr_reader :data

      # @api private
      def initialize(data)
        @data = data
      end

      # @api public
      def [](key)
        data[key]
      end
    end
  end
end