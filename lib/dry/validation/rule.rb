module Dry
  module Validation
    class Rule
      attr_reader :name, :block

      def initialize(name, &block)
        @name = name
        @block = block
      end

      def call(context, result)
        Evaluator.new(context, name: name, params: result, &block)
      end
    end
  end
end
