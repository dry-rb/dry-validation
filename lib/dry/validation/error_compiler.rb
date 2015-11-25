module Dry
  module Validation
    class ErrorCompiler
      attr_reader :config

      def initialize(config)
        @config = config[:errors]
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

      def visit_val(rule, name, value)
        name, predicate = rule
        [name, Array(visit(predicate, value, name))]
      end

      def visit_predicate(predicate, value, name)
        lookup_message(predicate[0], name) % visit(predicate, value).merge(name: name)
      end

      def visit_gt?(*args, value)
        { num: args[0][0], value: value }
      end

      def visit_filled?(*args)
        {}
      end

      def lookup_message(identifier, key)
        config.fetch(:attributes, {}).fetch(key, {}).fetch(identifier) {
          config.fetch(identifier)
        }
      end
    end
  end
end
