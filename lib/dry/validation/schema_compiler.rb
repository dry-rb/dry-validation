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
          result = nil
          Array(path).each do |name|
            curr = results[name]
            result = curr.success? if curr.respond_to?(:success)
          end
          result
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
        type.rule
      end
    end
  end
end
