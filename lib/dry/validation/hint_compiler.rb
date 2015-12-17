require 'dry/validation/error_compiler'

module Dry
  module Validation
    class HintCompiler < ErrorCompiler
      attr_reader :messages, :options

      def initialize(messages, options = {})
        @messages = messages
        @options = options
      end

      def call(ast)
        messages = Hash.new { |h, k| h[k] = [] }

        ast.flat_map { |node| visit(node) }.each do |hints|
          name, message = hints
          messages[name] << message
        end

        messages
      end

      def visit_and(node)
        left, right = node
        [visit(left), visit(right)].compact
      end

      def visit_key(node)
        nil
      end

      def visit_val(node)
        name, predicate = node
        [name, visit(predicate, name)]
      end

      def visit_predicate(node, name)
        predicate_name, args = node

        lookup_options = options.merge(rule: name, arg_type: args[0].class)

        template = messages[predicate_name, lookup_options]
        tokens = visit(predicate, value).merge(name: name)

        template % tokens
      end
    end
  end
end
