require 'dry/logic/predicates'

require 'dry/validation/schema_compiler'
require 'dry/validation/schema/key'
require 'dry/validation/schema/value'
require 'dry/validation/schema/check'

require 'dry/validation/error'
require 'dry/validation/result'
require 'dry/validation/messages'
require 'dry/validation/error_compiler'
require 'dry/validation/hint_compiler'

module Dry
  module Validation
    class Schema
      extend Dry::Configurable

      setting :path
      setting :predicates, Logic::Predicates
      setting :messages, :yaml
      setting :messages_file
      setting :namespace
      setting :rules, []
      setting :checks, []

      def self.new(rules = config.rules, **options)
        super(rules, default_options.merge(options))
      end

      def self.to_ast
        [:schema, self]
      end

      def self.rules
        config.rules
      end

      def self.predicates
        config.predicates
      end

      def self.messages
        default = default_messages

        if config.messages_file && config.namespace
          default.merge(config.messages_file).namespaced(config.namespace)
        elsif config.messages_file
          default.merge(config.messages_file)
        elsif config.namespace
          default.namespaced(config.namespace)
        else
          default
        end
      end

      def self.default_messages
        case config.messages
        when :yaml then Messages.default
        when :i18n then Messages::I18n.new
        else
          raise "+#{config.messages}+ is not a valid messages identifier"
        end
      end

      def self.error_compiler
        @error_compiler ||= ErrorCompiler.new(messages)
      end

      def self.hint_compiler
        @hint_compiler ||= HintCompiler.new(messages, rules: rule_ast)
      end

      def self.rule_ast
        @rule_ast ||= config.rules.flat_map(&:rules).map(&:to_ast)
      end

      def self.default_options
        { predicates: predicates,
          error_compiler: error_compiler,
          hint_compiler: hint_compiler,
          checks: config.checks }
      end

      attr_reader :rules

      attr_reader :checks

      attr_reader :predicates

      attr_reader :rule_compiler

      attr_reader :error_compiler

      attr_reader :hint_compiler

      def initialize(rules, options = {})
        @rules = rules
        @rule_compiler = SchemaCompiler.new(self)
        @error_compiler = options.fetch(:error_compiler)
        @hint_compiler = options.fetch(:hint_compiler)
        @predicates = options.fetch(:predicates)
        initialize_rules(rules)
        initialize_checks(options.fetch(:checks, []))
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

      def call(input)
        Result.new(input, errors(input), error_compiler, hint_compiler)
      end

      def errors(input)
        results = rule_results(input)

        results.merge!(check_results(input, results)) unless checks.empty?

        results
          .map { |name, result| Error.new(name, result) if result.failure? }
          .compact
      end

      def [](name)
        if predicates.key?(name)
          predicates[name]
        elsif respond_to?(name)
          Logic::Predicate.new(name, &method(name))
        else
          raise ArgumentError, "+#{name}+ is not a valid predicate name"
        end
      end

      private

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
    end
  end
end
