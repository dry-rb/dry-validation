module Dry
  module Validation
    class ErrorCompiler
      attr_reader :messages, :hints, :options

      DEFAULT_RESULT = {}.freeze
      KEY_SEPARATOR = '.'.freeze

      def initialize(messages, options = {})
        @messages = messages
        @options = Hash[options]
        @hints = @options.fetch(:hints, {})
      end

      def call(ast)
        merge(ast.map { |node| visit(node) }) || DEFAULT_RESULT
      end

      def with(new_options)
        self.class.new(messages, options.merge(new_options))
      end

      def input_visitor(name, input)
        Input.new(messages, options.merge(name: name, input: input))
      end

      def visit(node)
        __send__(:"visit_#{node[0]}", node[1])
      end

      def visit_input(node)
        name, value, other = node
        input_visitor(name, value).(other)
      end

      def visit_error(error)
        result = visit(error)

        if result.is_a?(Array)
          merge(result)
        else
          result.each_with_object({}) do |(name, msgs), res|
            if msgs.is_a?(Hash)
              res[name] = msgs
            else
              res[name] = [(msgs[0] + (hints[name] || [])).uniq, msgs[1]]
            end
          end
        end
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
        visit(predicate)
      end

      private

      def normalize_name(name)
        Array(name).join('.').to_sym
      end

      def merge(result)
        result.reduce do |a, e|
          e.merge(a) do |_, left, right|
            left.is_a?(Hash) ? left.merge(right) : right + left
          end
        end
      end
    end
  end
end

require 'dry/validation/error_compiler/input'
