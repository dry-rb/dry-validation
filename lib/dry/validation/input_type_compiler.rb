require 'dry/types'
require 'dry/types/compiler'

module Dry
  module Validation
    class InputTypeCompiler
      attr_reader :type_compiler

      TYPES = {
        default: 'string',
        none?: 'form.nil',
        bool?: 'form.bool',
        str?: 'string',
        int?: 'form.int',
        float?: 'form.float',
        decimal?: 'form.decimal',
        date?: 'form.date',
        date_time?: 'form.date_time',
        time?: 'form.time'
      }.freeze

      DEFAULT_TYPE_NODE = [[:type, 'string']].freeze

      def initialize
        @type_compiler = Dry::Types::Compiler.new(Dry::Types)
      end

      def call(ast)
        type_compiler.([:type, ['hash', [:symbolized, schema_ast(ast)]]])
      end

      def schema_ast(ast)
        ast.map { |node| visit(node) }
      end

      def visit(node, *args)
        send(:"visit_#{node[0]}", node[1], *args)
      end

      def visit_schema(node, *args)
        [:type, ['hash', [:symbolized, node.input_type_ast]]]
      end

      def visit_or(node, *args)
        left, right = node
        [:sum, [visit(left, *args), visit(right, *args)]]
      end

      def visit_and(node, first = true)
        if first
          name, type = node.map { |n| visit(n, false) }.uniq
          [:key, [name, type]]
        else
          result = node.map { |n| visit(n, first) }.uniq

          if result.size == 1
            result.first
          else
            (result - DEFAULT_TYPE_NODE).first
          end
        end
      end

      def visit_implication(node)
        key, types = node
        [:key, [visit(key), visit(types, false)]]
      end

      def visit_key(node, *args)
        _, other = node
        visit(other, *args)
      end

      def visit_val(node, *args)
        visit(node, *args)
      end

      def visit_set(node, *)
        [:type, ['form.hash', [:symbolized, node.map { |n| visit(n) }]]]
      end

      def visit_each(node, *args)
        [:type, ['form.array', visit(node, *args)]]
      end

      def visit_predicate(node, *args)
        id, args = node

        if id == :key?
          args[0]
        else
          [:type, TYPES[id] || TYPES[:default]]
        end
      end
    end
  end
end
