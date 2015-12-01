require 'dry/validation/rule'

module Dry
  module Validation
    class RuleCompiler
      attr_reader :predicates

      def initialize(predicates)
        @predicates = predicates
      end

      def call(ast)
        ast.map { |node| visit(node) }
      end

      def visit(node)
        name, nodes = node
        send(:"visit_#{name}", nodes)
      end

      def visit_key(node)
        name, predicate = node
        Rule::Key.new(name, visit(predicate))
      end

      def visit_val(node)
        name, predicate = node
        Rule::Value.new(name, visit(predicate))
      end

      def visit_set(node)
        name, rules = node
        Rule::Set.new(name, call(rules))
      end

      def visit_each(node)
        name, rule = node
        Rule::Each.new(name, visit(rule))
      end

      def visit_predicate(node)
        name, args = node
        predicates[name].curry(*args)
      end

      def visit_and(node)
        left, right = node
        visit(left) & visit(right)
      end

      def visit_or(node)
        left, right = node
        visit(left) | visit(right)
      end

      def visit_implication(node)
        left, right = node
        visit(left) > visit(right)
      end

      def visit_group(node)
        names, predicate = node
        Rule::Group.new(names, visit(predicate))
      end
    end
  end
end
