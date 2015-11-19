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
        input, rules = visit(error[0]), error[1..error.size-1]
        rules.flat_map { |rule| visit(rule, input) }
      end

      def visit_input(input)
        input
      end

      def visit_rule(rule, *args)
        name, predicate = rule
        [name, [visit(predicate, *args)]]
      end

      def visit_predicate(predicate, input)
        config[:errors][predicate[0]] % { value: input }
      end
    end
  end
end
