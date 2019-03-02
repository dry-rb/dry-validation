require 'dry/initializer'

module Dry
  module Validation
    class Rule
      extend Dry::Initializer

      option :name

      option :block

      def call(context, values)
        Evaluator.new(context, values: values, name: name, &block)
      end
    end
  end
end
