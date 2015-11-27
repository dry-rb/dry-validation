require 'dry/data'
require 'dry/data/compiler'

module Dry
  module Validation
    class InputTypeCompiler
      attr_reader :type_compiler

      TYPES = {
        str?: 'string', int?: 'form.int'
      }.freeze

      def initialize
        @type_compiler = Dry::Data::Compiler.new(Dry::Data)
      end

      def call(ast)
        type = type_compiler.([:type, ['hash', [:schema, ast.map { |node| visit(node) }]]])

        -> input { Validation.symbolize_keys(type[input]) }
      end

      def visit(node)
        send(:"visit_#{node[0]}", node[1])
      end

      def visit_and(node)
        left, right = node
        [:key, [visit(left), visit(right)]]
      end

      def visit_key(node)
        node[0].to_s
      end

      def visit_val(node)
        visit(node[1])
      end

      def visit_predicate(node)
        TYPES.fetch(node[0])
      end
    end
  end
end
