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
        messages.lookup(predicate[0], name, predicate[1][0]) % visit(predicate, value).merge(name: name)
      end

      def visit_key?(*args, value)
        { name: args[0][0] }
      end

      def visit_empty?(*args, value)
        { value: value }
      end

      def visit_exclusion?(*args, value)
        { list: args[0][0].join(', ') }
      end

      def visit_inclusion?(*args, value)
        { list: args[0][0].join(', ') }
      end

      def visit_gt?(*args, value)
        { num: args[0][0], value: value }
      end

      def visit_gteq?(*args, value)
        { num: args[0][0], value: value }
      end

      def visit_lt?(*args, value)
        { num: args[0][0], value: value }
      end

      def visit_lteq?(*args, value)
        { num: args[0][0], value: value }
      end

      def visit_int?(*args, value)
        { num: args[0][0], value: value }
      end

      def visit_max_size?(*args, value)
        { num: args[0][0], value: value }
      end

      def visit_min_size?(*args, value)
        { num: args[0][0], value: value }
      end

      def visit_size?(*args, value)
        num = args[0][0]

        if num.is_a?(Range)
          { left: num.first, right: num.last, value: value }
        else
          { num: args[0][0], value: value }
        end
      end

      def visit_str?(*args, value)
        { value: value }
      end

      def visit_format?(*args, value)
        {}
      end

      def visit_nil?(*args, value)
        {}
      end

      def visit_filled?(*args)
        {}
      end
    end
  end
end
