module Dry
  module Validation
    class ErrorCompiler
      attr_reader :messages, :hints, :options

      DEFAULT_RESULT = {}.freeze
      KEY_SEPARATOR = '.'.freeze

      def initialize(messages, options = {})
        @messages = messages
        @options = Hash[options]
        @hints = @options.delete(:hints) || {}
      end

      def call(ast)
        merge(ast.map { |node| visit(node) }) || DEFAULT_RESULT
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

      def visit_input(node, *args)
        path, value, rules = node
        name = normalize_name(path)

        parent, _ = args

        err_hash = ([errors_for(rules, name, value)] + Array(path).reverse)
          .reduce { |a, e| { e => a } }

        if parent && err_hash.key?(parent)
          err_hash[parent]
        else
          err_hash
        end
      end

      def visit_group(_, name, _)
        messages[name, rule: name]
      end

      def visit_check(node, *args)
        name, other = node
        messages[normalize_name(name), rule: name] || visit(other, *args)
      end

      def visit_implication(node, *args)
        _, right = node
        visit(right, *args)
      end

      def visit_res(node, *args)
        _, predicate = node
        visit(predicate, *args)
      end

      def visit_key(rule, *args)
        _, predicate = rule
        visit(predicate, *args)
      end

      def visit_attr(rule, *args)
        _, predicate = rule
        visit(predicate, *args)
      end

      def visit_val(rule, *args)
        _, predicate = rule
        visit(predicate, *args)
      end

      def visit_predicate(predicate, identifier, value)
        predicate_name, args = predicate

        name = identifier.to_s.split(KEY_SEPARATOR).last

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

      private

      def errors_for(rules, name, value)
        hints = hints_for(name)
        errors = rules.map { |rule| visit(rule, name, value) }.flatten

        [(errors + hints).uniq, value]
      end

      def hints_for(name)
        hints[name] || []
      end

      def normalize_name(name)
        Array(name).join(KEY_SEPARATOR).to_sym
      end

      def merge(result)
        result.reduce do |a, e|
          e.merge(a) do |_, l, r|
            l.is_a?(Hash) ? l.merge(r) : l + r
          end
        end
      end

      def method_missing(_meth, *args)
        { value: args[1] }
      end
    end
  end
end
