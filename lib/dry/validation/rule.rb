require 'dry/equalizer'
require 'dry/initializer'

module Dry
  module Validation
    # Rules are created by contracts
    #
    # @api private
    class Rule
      include Dry::Equalizer(:name, :block)

      extend Dry::Initializer

      # @!atrribute [r] keys
      #   @return [Array<Symbol, String, Hash>]
      #   @api private
      option :keys

      # @!atrribute [r] block
      #   @return [Proc]
      #   @api private
      option :block

      # Evaluate the rule within the provided context
      #
      # @param [Contract] context
      # @param [Object] values
      #
      # @api private
      def call(context, values)
        Evaluator.new(context, values: values, keys: keys, &block)
      end
    end
  end
end
