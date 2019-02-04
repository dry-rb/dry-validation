module Dry
  module Validation
    class Rule
      attr_reader :name, :paths, :block

      def initialize(paths, &block)
        @name = paths.first
        @paths = paths
        @block = block
      end

      def call(result)
        evaluator = Evaluator.new(name, result, &block)
        evaluator
      end
    end
  end
end
