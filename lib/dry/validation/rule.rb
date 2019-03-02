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

      # @!atrribute [r] name
      #   @return [Symbol]
      #   @api private
      option :name

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
        Evaluator.new(context, values: values, name: name, &block)
      end
    end
  end
end
