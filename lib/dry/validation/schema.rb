require 'dry/logic/predicates'
require 'dry/types/constraints'

require 'dry/validation/predicate_registry'
require 'dry/validation/schema_compiler'
require 'dry/validation/schema/key'
require 'dry/validation/schema/value'
require 'dry/validation/schema/check'

require 'dry/validation/error'
require 'dry/validation/result'
require 'dry/validation/messages'
require 'dry/validation/error_compiler'
require 'dry/validation/hint_compiler'

require 'dry/validation/schema/deprecated'
require 'dry/validation/schema/class_interface'

module Dry
  module Validation
    class Schema
      attr_reader :rules

      attr_reader :checks

      attr_reader :predicates

      attr_reader :input_processor

      attr_reader :rule_compiler

      attr_reader :error_compiler

      attr_reader :hint_compiler

      attr_reader :options

      attr_reader :type_map

      def initialize(rules, options)
        @type_map = self.class.type_map
        @predicates = options.fetch(:predicate_registry).bind(self)
        @rule_compiler = SchemaCompiler.new(predicates, options)
        @error_compiler = options.fetch(:error_compiler)
        @hint_compiler = options.fetch(:hint_compiler)
        @input_processor = options.fetch(:input_processor, NOOP_INPUT_PROCESSOR)

        initialize_options(options)
        initialize_rules(rules)
        initialize_checks(options.fetch(:checks, []))

        freeze
      end

      def with(new_options)
        self.class.new(self.class.rules, options.merge(new_options))
      end

      def call(input)
        processed_input = input_processor[input]
        Result.new(processed_input, apply(processed_input), error_compiler, hint_compiler)
      end

      def curry(*curry_args)
        -> *args { call(*(curry_args + args)) }
      end

      def to_proc
        -> input { call(input) }
      end

      def arity
        1
      end

      def to_ast
        self.class.to_ast
      end

      private

      def apply(input)
        results = rule_results(input)

        results.merge!(check_results(input, results)) unless checks.empty?

        results
          .select { |_, result| result.failure? }
          .map { |name, result| Error.new(error_path(name), result) }
      end

      def error_path(name)
        full_path = Array[*self.class.config.path]
        full_path << name
        full_path.size > 1 ? full_path : full_path[0]
      end

      def rule_results(input)
        rules.each_with_object({}) do |(name, rule), hash|
          hash[name] = rule.(input)
        end
      end

      def check_results(input, result)
        checks.each_with_object({}) do |(name, check), hash|
          check_res = check.is_a?(Guard) ? check.(input, result) : check.(input)
          hash[name] = check_res if check_res
        end
      end

      def initialize_options(options)
        @options = options

        self.class.options.each do |name, default|
          value = options.fetch(name) do
            case default
            when Proc then default.()
            else default end
          end

          instance_variable_set("@#{name}", value)
        end
      end

      def initialize_rules(rules)
        @rules = rules.each_with_object({}) do |rule, result|
          result[rule.name] = rule_compiler.visit(rule.to_ast)
        end
      end

      def initialize_checks(checks)
        @checks = checks.each_with_object({}) do |check, result|
          result[check.name] = rule_compiler.visit(check.to_ast)
        end
      end
    end
  end
end
