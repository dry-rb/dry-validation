module Dry
  module Validation
    class ErrorCompiler
      attr_reader :messages

      def initialize(messages)
        @messages = messages
      end

      def call(ast)
        ast.map { |node| visit(node) }
      end

      def visit(node, *args)
        __send__(:"visit_#{node[0]}", node[1], *args)
      end

      def visit_error(error)
        visit(error)
      end

      def visit_input(input, *args)
        name, value, rules = input
        [name, rules.map { |rule| visit(rule, name, value) }]
      end

      def visit_key(rule, name, value)
        _, predicate = rule
        visit(predicate, value, name)
      end

      def visit_val(rule, name, value)
        name, predicate = rule
        visit(predicate, value, name)
      end

      def visit_predicate(predicate, value, name)
        messages.lookup(predicate[0], name) % visit(predicate, value).merge(name: name)
      end

      def visit_key?(*args, value)
        { name: args[0][0] }
      end

      def visit_gt?(*args, value)
        { num: args[0][0], value: value }
      end

      def visit_filled?(*args)
        {}
      end
    end
  end
end
