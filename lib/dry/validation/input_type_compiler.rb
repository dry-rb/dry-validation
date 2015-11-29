require 'dry/data'
require 'dry/data/compiler'

module Dry
  module Validation
    class InputTypeCompiler
      attr_reader :type_compiler

      TYPES = {
        str?: 'string', none?: 'form.nil', int?: 'form.int'
      }.freeze

      def initialize
        @type_compiler = Dry::Data::Compiler.new(Dry::Data)
      end

      def call(ast)
        schema = ast.map { |node| visit(node) }
        type_compiler.([:type, ['hash', [:symbolized, schema]]])
      end

      def visit(node)
        send(:"visit_#{node[0]}", node[1])
      end

      def visit_or(node)
        left, right = node

        left_type = visit(left)
        right_type = visit(right)

        [left_type, right_type]
      end

      def visit_and(node)
        left, right = node

        name = visit(left)
        type = visit(right)

        if type
          [:key, [name, Array(type)]]
        else
          name
        end
      end

      def visit_key(node)
        node[0].to_s
      end

      def visit_val(node)
        visit(node[1])
      end

      def visit_predicate(node)
        TYPES[node[0]]
      end
    end
  end
end
