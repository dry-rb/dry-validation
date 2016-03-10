module Dry
  module Validation
    class ErrorCompiler
      attr_reader :messages, :hints, :options

      DEFAULT_RESULT = {}.freeze
      EMPTY_HINTS = [].freeze
      KEY_SEPARATOR = '.'.freeze

      def initialize(messages, options = {})
        @messages = messages
        @options = Hash[options]
        @hints = @options.fetch(:hints, {})
      end

      def call(ast, *args)
        merge(ast.map { |node| visit(node, *args) }) || DEFAULT_RESULT
      end

      def with(new_options)
        self.class.new(messages, options.merge(new_options))
      end

      def visit(node, *args)
        __send__(:"visit_#{node[0]}", node[1], *args)
      end

      def visit_schema(node, *args)
        visit_error(node[1], true)
      end

      def visit_set(node, *args)
        call(node, *args)
      end

      def visit_error(error, schema = false)
        name, other = error
        message = messages[name, rule: name]

        if message
          { name => [message] }
        else
          result = schema ? visit(other, name) : visit(other)

          if result.is_a?(Array)
            merge(result)
          else
            merge_hints(result)
          end
        end
      end

      def visit_input(node, path = nil)
        name, result = node
        visit(result, path || name)
      end

      def visit_result(node, name = nil)
        value, other = node
        input_visitor(name, value).visit(other)
      end

      def visit_implication(node)
        _, right = node
        visit(right)
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
        visit(node)
      end

      private

      def merge_hints(messages)
        messages.each_with_object({}) do |(name, msgs), res|
          if msgs.is_a?(Hash)
            res[name] = merge_hints(msgs)
          else
            all_msgs = msgs + (hints[name] || EMPTY_HINTS)
            all_msgs.uniq!

            res[name] = all_msgs
          end
        end
      end

      def normalize_name(name)
        Array(name).join('.').to_sym
      end

      def merge(result)
        result.reduce do |a, e|
          e.merge(a) do |_, left, right|
            if left.is_a?(Hash)
              left.merge(right)
            else
              right + left
            end
          end
        end
      end

      def input_visitor(name, input)
        Input.new(messages, options.merge(name: name, input: input))
      end
    end
  end
end

require 'dry/validation/error_compiler/input'
