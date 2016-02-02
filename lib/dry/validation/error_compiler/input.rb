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

      def input_visitor(new_name, value)
        self.class.new(messages, options.merge(name: [*name, *new_name].uniq, input: value))
      end

      def visit_el(node)
        idx, element = node
        with(name: [*Array(name), idx], input: input[idx]).(element.last.last)
      end

      def visit_predicate(node)
        predicate, args = node

        lookup_options = options.merge(
          rule: rule, val_type: val_type, arg_type: args[0].class
        )

        template = messages[predicate, lookup_options]
        tokens = __send__(:"options_for_#{predicate}", args).merge(name: rule)

        message = [[template % tokens], input]

        if name.is_a?(Array)
          [message, *name.reverse].reduce { |a, e| { e => a } }
        else
          { name => message }
        end
      end

      def options_for_key?(*args)
        { name: args[0][0] }
      end

      def options_for_attr?(*args)
        { name: args[0][0] }
      end

      def options_for_exclusion?(*args)
        { list: args[0][0].join(', ') }
      end

      def options_for_inclusion?(*args)
        { list: args[0][0].join(', ') }
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

      def options_for_size?(*args)
        num = args[0][0]

        if num.is_a?(Range)
          { left: num.first, right: num.last, value: input }
        else
          { num: args[0][0], value: value }
        end
      end

      private

      def method_missing(*)
        { name: name, value: input }
      end
    end
  end
end
