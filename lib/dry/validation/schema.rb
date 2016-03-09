require 'dry/logic/predicates'

require 'dry/validation/schema_compiler'
require 'dry/validation/schema/key'
require 'dry/validation/schema/value'
require 'dry/validation/schema/check'

require 'dry/validation/error'
require 'dry/validation/messages'
require 'dry/validation/error_compiler'
require 'dry/validation/hint_compiler'
require 'dry/validation/result'
require 'dry/validation/schema/result'

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

      def self.error_compiler
        ErrorCompiler.new(messages)
      end

      def self.hint_compiler
        HintCompiler.new(messages, rules: rule_ast)
      end

      def self.rule_ast
        config.rules.flat_map(&:rules).map(&:to_ast)
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

      def self.default_options
        { error_compiler: error_compiler,
          hint_compiler: hint_compiler,
          checks: config.checks }
      end

      attr_reader :rules

      attr_reader :checks

      attr_reader :rule_compiler

      attr_reader :error_compiler

      attr_reader :hint_compiler

      def initialize(rules, options = {})
        @rules = rules
        @rule_compiler = SchemaCompiler.new(self)
        @error_compiler = options.fetch(:error_compiler)
        @hint_compiler = options.fetch(:hint_compiler)
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
        resmap = Hash[rules.map { |name, rule| [name, rule.(input)] }]
        result = Validation::Result.new(resmap)

        chkmap = Hash[
          checks.map { |name, check|
            check_res = check.is_a?(Guard) ? check.(input, result) : check.(input)
            [name, check_res] if check_res
          }.compact
        ]

        result.merge!(chkmap)

        errors = result.failures.map do |name, failure|
          if failure.is_a?(Schema::Result)
            failure
          else
            Error.new(name, failure, error_compiler, hint_compiler)
          end
        end

        Schema::Result.new(input, result, errors)
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

      def predicates
        self.class.predicates
      end
    end
  end
end
