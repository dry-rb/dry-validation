require 'dry/validation/rule'

module Dry
  module Validation
    class RuleCompiler
      def call(ast)
        ast.map { |node| visit(node) }
      end

      def visit(node)
        name, nodes = node
        send(:"visit_#{name}", nodes)
      end

      def visit_key_rule(node)
        name, predicate = node
        Rule::Key.new(name, visit(predicate))
      end

      def visit_val_rule(node)
        name, predicate = node
        Rule::Value.new(name, visit(predicate))
      end

      def visit_predicate(node)
        _, fn = node
        fn
      end

      def visit_and(node)
        left, right = node
        visit(left) & visit(right)
      end

      def visit_or(node)
        left, right = node
        visit(left) | visit(right)
      end
    end
  end
end
