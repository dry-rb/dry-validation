require 'dry/data'
require 'dry/data/compiler'

module Dry
  module Validation
    class InputTypeCompiler
      attr_reader :type_compiler

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

      def visit_key(node)
        name, predicate = node
        [:key, [name.to_s, visit(predicate)]]
      end

      def visit_predicate(node)
        'string'
      end
    end
  end
end
