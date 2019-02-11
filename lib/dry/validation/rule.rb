require 'dry/initializer'

module Dry
  module Validation
    class Rule
      extend Dry::Initializer

      option :name
      
      option :block

      def call(context, params)
        Evaluator.new(context, params: params, name: name, &block)
      end
    end
  end
end
