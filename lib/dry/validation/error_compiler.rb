module Dry
  module Validation
    class ErrorCompiler
      attr_reader :config

      def initialize(config)
        @config = config
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

      def visit_input(input)
        name, value, rule = input
        visit(rule, name, value)
      end

      def visit_rule(rule, name, value)
        name, predicate = rule
        [name, Array(visit(predicate, value, name))]
      end

      def visit_predicate(predicate, input, name)
        identifier, args = predicate
        config[:errors][identifier] % visit(predicate, *args).merge(name: name)
      end

      def visit_gt?(*args)
        { value: args[0], num: args[1] }
      end

      def visit_filled?(*args)
        {}
      end
    end
  end
end
