require 'dry/initializer'

module Dry
  module Validation
    class Rule
      extend Dry::Initializer

      # @!attribute[r] name
      #   @return [Symbol] The name of the rule
      #   @api public
      option :name, proc(&:to_sym)

      # @!attribute[r] block
      #   @return [Proc] Code that will be evaluated
      #   @api public
      option :block

      # @api private
      def call(context, params)
        Evaluator.new(context, params: params, name: name, &block)
      end
    end
  end
end
