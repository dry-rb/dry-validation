require 'dry/types'
require 'dry/types/compiler'

module Dry
  module Validation
    class InputProcessorCompiler
      attr_reader :type_compiler

      DEFAULT_TYPE_NODE = [:definition, [String, {}]].freeze

      def initialize
        @type_compiler = Dry::Types::Compiler.new(Dry::Types)
      end

      def call(ast)
        type_compiler.(hash_node(schema_ast(ast)))
      end

      def schema_ast(ast)
        ast.map { |node| visit(node) }
      end

      def visit(node, *args)
        send(:"visit_#{node[0]}", node[1], *args)
      end

      def visit_rule(node, *args)
        _, rule = node
        visit(rule, *args)
      end

      def visit_type(type, *args)
        if type.is_a?(Types::Constructor)
          constructor(type)
        elsif type.respond_to?(:rule)
          visit(type.rule.to_ast, *args)
        end
      end

      def constructor(type)
        fn_id = type.__send__(:register_fn, type.fn)
        [:constructor, [[:definition, [type.primitive, {}]], fn_id, {}]]
      end

      def visit_schema(schema, *args)
        hash_node(schema.input_processor_ast(identifier))
      end

      def visit_or(node, *args)
        left, right = node
        [:sum, [visit(left, *args), visit(right, *args), {}]]
      end

      def visit_and(node, first = true)
        if first
          name, type = node.map { |n| visit(n, false) }.uniq

          if name.is_a?(Array)
            type
          else
            [:member, [name, type]]
          end
        else
          result = node.map { |n| visit(n, first) }.uniq

          if result.size == 1
            result.first
          else
            result.select { |r| r != self.class::DEFAULT_TYPE_NODE }.last
          end
        end
      end

      def visit_implication(node, *args)
        left, right = node

        key = visit(left)

        if key.is_a?(Symbol)
          [:member, [key, visit(right, false)]]
        else
          [:sum, [key, visit(right, false), {}]]
        end
      end

      def visit_not(node, *args)
        visit(node, *args)
      end

      def visit_key(node, *args)
        _, other = node
        visit(other, *args)
      end

      def visit_val(node, *args)
        visit(node, *args)
      end

      def visit_set(node, *)
        hash_node(node.map { |n| visit(n) })
      end

      def visit_each(node, *args)
        array_node(visit(node, *args))
      end

      def visit_predicate(node, *)
        id, args = node

        if id == :key?
          args[0][1]
        else
          type(id, args.map(&:last))
        end
      end

      def type(predicate, args)
        default = self.class::PREDICATE_MAP[:default]

        type_value = if predicate == :type?
                       const = args[0]
                       self.class::CONST_MAP[const] || Types.identifier(const)
                     else
                       self.class::PREDICATE_MAP[predicate] || default
                     end
        Types[type_value].to_ast
      end
    end
  end
end

require 'dry/validation/input_processor_compiler/sanitizer'
require 'dry/validation/input_processor_compiler/json'
require 'dry/validation/input_processor_compiler/form'
