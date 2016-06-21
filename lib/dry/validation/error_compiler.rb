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
        @full = options.fetch(:full, false)
      end

      def full?
        @full
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
        message = messages[name]

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

      def dump_messages(hash)
        hash.each_with_object({}) do |(key, val), res|
          res[key] =
            case val
            when Hash then dump_messages(val)
            when Array then val.map(&:to_s)
            end
        end
      end

      private

      def merge_hints(messages)
        messages.each_with_object({}) do |(name, msgs), res|
          res[name] =
            if msgs.is_a?(Hash)
              res[name] = merge_hints(msgs)
            else
              all_msgs = msgs + (hints[name] || EMPTY_HINTS)
              all_msgs.uniq!(&:signature)
              all_msgs
            end
        end
      end

      def normalize_name(name)
        Array(name).join('.').to_sym
      end

      def merge(result)
        result.reduce { |a, e| deep_merge(a, e) } || DEFAULT_RESULT
      end

      def deep_merge(left, right)
        left.merge(right) do |_, a, e|
          if a.is_a?(Hash)
            deep_merge(a, e)
          else
            a + e
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
