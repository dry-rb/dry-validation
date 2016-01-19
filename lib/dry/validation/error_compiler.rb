module Dry
  module Validation
    class ErrorCompiler
      attr_reader :messages, :options

      DEFAULT_RESULT = {}.freeze

      def initialize(messages, options = {})
        @messages = messages
        @options = options
      end

      def call(ast)
        ast.map { |node| visit(node) }.reduce(:merge) || DEFAULT_RESULT
      end

      def with(new_options)
        self.class.new(messages, options.merge(new_options))
      end

      def visit(node, *args)
        __send__(:"visit_#{node[0]}", node[1], *args)
      end

      def visit_error(error)
        visit(error)
      end

      def visit_input(input, *args)
        name, value, rules = input
        { name => [rules.map { |rule| visit(rule, name, value) }, value] }
      end

      def visit_check(node, *args)
        name, _ = node
        messages[name, rule: name]
      end

      def visit_key(rule, name, value)
        _, predicate = rule
        visit(predicate, value, name)
      end

      def visit_attr(rule, name, value)
        _, predicate = rule
        visit(predicate, value, name)
      end

      def visit_val(rule, name, value)
        name, predicate = rule
        visit(predicate, value, name)
      end

      def visit_predicate(predicate, value, name)
        predicate_name, args = predicate

        lookup_options = options.merge(
          rule: name, val_type: value.class, arg_type: args[0].class
        )

        template = messages[predicate_name, lookup_options]
        tokens = visit(predicate, value).merge(name: name)

        template % tokens
      end

      def visit_key?(*args, _value)
        { name: args[0][0] }
      end

      def visit_attr?(*args, _value)
        { name: args[0][0] }
      end

      def visit_exclusion?(*args, _value)
        { list: args[0][0].join(', ') }
      end

      def visit_inclusion?(*args, _value)
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

      def visit_eql?(*args, value)
        { eql_value: args[0][0], value: value }
      end

      def visit_size?(*args, value)
        num = args[0][0]

        if num.is_a?(Range)
          { left: num.first, right: num.last, value: value }
        else
          { num: args[0][0], value: value }
        end
      end

      def method_missing(_meth, *args)
        { value: args[1] }
      end
    end
  end
end
