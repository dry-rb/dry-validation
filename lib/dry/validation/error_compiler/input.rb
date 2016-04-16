module Dry
  module Validation
    class ErrorCompiler::Input < ErrorCompiler
      attr_reader :name, :input, :rule, :val_type

      def initialize(messages, options)
        super
        @name = options.fetch(:name)
        @input = options.fetch(:input)
        @rule = Array(name).last
        @val_type = input.class
      end

      def visit_each(node)
        node.map { |el| visit(el) }
      end

      def visit_set(node, *)
        result = node.map do |input|
          visit(input)
        end
        merge(result)
      end

      def visit_el(node)
        idx, el = node
        path = [*Array(name), idx]
        input_visitor(path, input[idx]).visit(el)
      end

      def visit_check(node)
        _, other = node
        visit(other)
      end

      def visit_predicate(node)
        predicate, args = node

        lookup_options = options.merge(
          rule: rule, val_type: val_type, arg_type: args[0].class
        )

        tokens = options_for(predicate, args)
        template = messages[predicate, lookup_options.merge(tokens)]

        unless template
          raise MissingMessageError.new("message for #{predicate} was not found")
        end

        rule_name =
          if rule.is_a?(Symbol)
            messages.rule(rule, lookup_options) || rule
          else
            rule
          end

        message =
          if full?
            "#{rule_name} #{template % tokens}"
          else
            template % tokens
          end

        path = [[message], *[tokens[:name], *Array(name).reverse].uniq]

        path.reduce { |a, e| { e => a } }
      end

      def options_for_type?(*args)
        { type: args[0][0] }
      end

      def options_for_key?(*args)
        { name: args[0][0] }
      end

      def options_for_attr?(*args)
        { name: args[0][0] }
      end

      def options_for_excluded_from?(*args)
        { list: args[0][0].join(', ') }
      end

      def options_for_excludes?(*args)
        { value: args[0][0] }
      end

      def options_for_included_in?(*args)
        { list: args[0][0].join(', ') }
      end

      def options_for_includes?(*args)
        { value: args[0][0] }
      end

      def options_for_gt?(*args)
        { num: args[0][0], value: input }
      end

      def options_for_gteq?(*args)
        { num: args[0][0], value: input }
      end

      def options_for_lt?(*args)
        { num: args[0][0], value: input }
      end

      def options_for_lteq?(*args)
        { num: args[0][0], value: input }
      end

      def options_for_int?(*args)
        { num: args[0][0], value: input }
      end

      def options_for_max_size?(*args)
        { num: args[0][0], value: input }
      end

      def options_for_min_size?(*args)
        { num: args[0][0], value: input }
      end

      def options_for_eql?(*args)
        { eql_value: args[0][0], value: input }
      end

      def options_for_not_eql?(*args)
        { eql_value: args[0][0], value: input }
      end

      def options_for_size?(*args)
        num = args[0][0]

        if num.is_a?(Range)
          { left: num.first, right: num.last, value: input }
        else
          { num: args[0][0], value: input }
        end
      end

      def options_for(predicate, args)
        meth = :"options_for_#{predicate}"

        defaults = { name: rule, rule: rule, value: input }

        if respond_to?(meth)
          defaults.merge!(__send__(meth, args))
        end

        defaults
      end

      def input_visitor(new_name, value)
        self.class.new(messages, options.merge(name: [*name, *new_name].uniq, input: value))
      end
    end
  end
end
