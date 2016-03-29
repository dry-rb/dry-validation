require 'dry/logic/rule_compiler'

module Dry
  module Validation
    class Guard
      attr_reader :rule, :deps

      def initialize(rule, deps)
        @rule = rule
        @deps = deps
      end

      def call(input, results)
        rule.(input) if deps_valid?(results)
      end

      private

      def deps_valid?(results)
        deps.all? do |path|
          result = Array(path).reduce(results) { |a, e| a[e] }
          result.success? if result
        end
      end
    end

    class DryType
      attr_reader :type

      def initialize(type)
        @type = type
      end

      def rule_ast
        case type
        when Dry::Types::Constrained, Dry::Types::Enum
          type.rule
        end
      end
    end

    class SchemaCompiler < Logic::RuleCompiler
      def visit_schema(klass)
        klass.new
      end

      def visit_guard(node)
        deps, other = node
        Guard.new(visit(other), deps)
      end

      def visit_type(type)
        DryType.new(type).rule_ast
      end
    end
  end
end
