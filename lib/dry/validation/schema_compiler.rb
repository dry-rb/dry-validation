require 'dry/logic/rule_compiler'

module Dry
  module Validation
    class Guard
      attr_reader :rule, :deps

      def initialize(rule, deps)
        @rule = rule
        @deps = deps
      end

      def call(input, result)
        if deps.all? { |path| Array(path).reduce(result) { |a, e| a[e] }.success? }
          rule.(input)
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
    end
  end
end
