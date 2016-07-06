require 'dry/validation/message_compiler'

module Dry
  module Validation
    class ErrorCompiler < MessageCompiler
      def message_type
        :failure
      end

      def message_class
        Message
      end

      def visit_error(node, opts = EMPTY_HASH)
        rule, error = node
        node_path = Array(opts.fetch(:path, rule))

        path = if rule.is_a?(Array) && rule.size > node_path.size
                 rule
               else
                 node_path
               end

        path.compact!

        text = messages[rule]

        if text
          Message.new(node, path, text, rule: rule)
        else
          visit(error, opts.merge(path: path))
        end
      end

      def visit_input(node, opts = EMPTY_HASH)
        rule, result = node
        visit(result, opts.merge(rule: rule))
      end

      def visit_result(node, opts = EMPTY_HASH)
        input, other = node
        visit(other, opts.merge(input: input))
      end

      def visit_each(node, opts = EMPTY_HASH)
        node.map { |el| visit(el, opts.merge(each: true)) }
      end

      def visit_schema(node, opts = EMPTY_HASH)
        path, other = node
        opts[:path] << path.last if opts[:path]
        visit(other, opts)
      end

      def visit_check(node, opts = EMPTY_HASH)
        path, other = node
        visit(other, opts.merge(path: Array(path)))
      end
    end
  end
end
