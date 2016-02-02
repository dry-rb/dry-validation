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

      def input(name, input)
        Input.new(messages, options.merge(name: name, input: input))
      end

      def visit(node)
        __send__(:"visit_#{node[0]}", node[1])
      end

      def visit_input(node)
        name, input, other = node

        messages = Array(input(name, input).(other))

        { name => [messages, input] }
      end

      def visit_error(error)
        result = visit(error)

        if result.is_a?(Array)
          merge(result)
        else
          result
        end
      end

      def visit_arr(node)
        raise NotImplementedError
      end

      def visit_el(node)
        raise NotImplementedError
      end

      def visit_check(node)
        name, other = node
        messages[normalize_name(name), rule: name] || visit(other)
      end

      def visit_implication(node)
        _, right = node
        visit(right)
      end

      def visit_res(node)
        _, predicate = node
        visit(predicate)
      end

      def visit_key(rule)
        _, predicate = rule
        visit(predicate)
      end

      def visit_attr(rule)
        _, predicate = rule
        visit(predicate)
      end

      def visit_val(node)
        _, predicate = node
        Array(visit(predicate))
      end

      private

      def hints_for(name)
        hints[normalize_name(name)] || []
      end

      def merge(result)
        result.reduce do |a, e|
          e.merge(a) do |_, l, r|
            l.is_a?(Hash) ? l.merge(r) : l + r
          end
        end
      end
    end
  end
end

require 'dry/validation/error_compiler/input'
