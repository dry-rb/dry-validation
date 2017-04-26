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

      def with(options)
        self.class.new(rule.with(options), deps)
      end

      private

      def deps_valid?(results)
        deps.all? do |path|
          result = nil
          Array(path).each do |name|
            curr = results[name]
            if curr
              result = curr.is_a?(Array) ? curr.first.success? : curr.success?
            end
          end
          result
        end
      end
    end

    class SchemaCompiler < Logic::RuleCompiler
      attr_reader :schema, :options

      def initialize(*args, options)
        super(*args)
        @options = options
        @schema = predicates.schema
      end

      def visit_rule(node)
        id, other = node
        visit(other).with(id: id)
      end

      def visit_predicate(node)
        super.eval_args(schema)
      end

      def visit_custom(node)
        id, predicate = node
        Logic::Rule.new(predicate).with(id: id).bind(schema)
      end

      def visit_schema(klass)
        opt_keys = klass.config.options.keys
        opt_vals = options.values_at(*opt_keys).compact

        if opt_vals.empty?
          klass.new
        else
          klass.new(klass.config.rules, Hash[opt_keys.zip(opt_vals)])
        end
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
