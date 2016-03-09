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
