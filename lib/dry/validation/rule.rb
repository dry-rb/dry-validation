module Dry
  module Validation
    class Rule
      attr_reader :name, :paths, :block

      def initialize(paths, &block)
        @name = paths.first
        @paths = paths
        @block = block
      end

      def call(context, result)
        Evaluator.new(context, name: name, params: result, &block)
      end
    end
  end
end
