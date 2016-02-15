require 'dry/validation/error_compiler/input'

module Dry
  module Validation
    class HintCompiler < ErrorCompiler::Input
      attr_reader :rules, :excluded

      EXCLUDED = [:none?].freeze

      def initialize(messages, options = {})
        super(messages, { name: nil, input: nil }.merge(options))
        @rules = @options.delete(:rules)
        @excluded = @options.fetch(:excluded, EXCLUDED)
      end

      def with(new_options)
        super(new_options.merge(rules: rules))
      end

      def call
        super(rules)
      end

      def visit_predicate(node)
        predicate, _ = node

        return {} if excluded.include?(predicate)

        super
      end

      def visit_set(node)
        merge(node.map { |el| visit(el) })
      end

      def visit_or(node)
        left, right = node
        merge([visit(left), visit(right)])
      end

      def visit_each(node)
        visit(node)
      end

      def visit_and(node)
        _, right = node
        visit(right)
      end

      def visit_implication(node)
        _, right = node
        visit(right)
      end

      def visit_key(node)
        name, predicate = node
        with(name: name).visit(predicate)
      end
      alias_method :visit_attr, :visit_key

      def visit_val(node)
        visit(node)
      end
    end
  end
end
