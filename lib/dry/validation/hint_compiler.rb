require 'dry/validation/error_compiler'

module Dry
  module Validation
    class HintCompiler < ErrorCompiler
      attr_reader :rules

      def initialize(messages, options = {})
        super
        @rules = @options.delete(:rules)
      end

      def with(new_options)
        super(new_options.merge(rules: rules))
      end

      def call
        super(rules)
      end

      def visit_or(node)
        left, right = node
        [visit(left), Array(visit(right)).flatten.compact].compact
      end

      def visit_and(node)
        left, right = node
        [visit(left), Array(visit(right)).flatten.compact].compact
      end

      def visit_implication(node)
        left, right = node
        [visit(left), Array(visit(right)).flatten.compact].compact
      end

      def visit_val(node)
        _, predicate = node
        Array(visit(predicate)).flatten.compact
      end

      def visit_key(node)
        name, _ = node
        name
      end

      def visit_attr(node)
        name, _ = node
        name
      end

      private

      def method_missing(*)
        {}
      end
    end
  end
end
