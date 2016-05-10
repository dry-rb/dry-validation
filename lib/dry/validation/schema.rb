require 'dry/types/constraints'

require 'dry/validation/schema_compiler'
require 'dry/validation/schema/key'
require 'dry/validation/schema/value'
require 'dry/validation/schema/check'

require 'dry/validation/error'
require 'dry/validation/result'
require 'dry/validation/messages'
require 'dry/validation/error_compiler'
require 'dry/validation/hint_compiler'

require 'dry/validation/input_processor_compiler'

module Dry
  module Validation
    class Schema
      extend Dry::Configurable

      NOOP_INPUT_PROCESSOR = -> input { input }

      setting :path
      setting :predicates, Types::Predicates
      setting :messages, :yaml
      setting :messages_file
      setting :namespace
      setting :rules, []
      setting :checks, []
      setting :options, {}

      setting :input_processor, :noop

      setting :input_processor_map, {
        sanitizer: InputProcessorCompiler::Sanitizer.new,
        json: InputProcessorCompiler::JSON.new,
        form: InputProcessorCompiler::Form.new,
      }.freeze

      def self.inherited(klass)
        super
        klass.config.options = klass.config.options.dup
      end

      def self.new(rules = config.rules, **options)
        super(rules, default_options.merge(options))
      end

      def self.create_class(target, other = nil, &block)
        klass =
          if other.is_a?(self)
            Class.new(other.class)
          elsif other.is_a?(Class) && other < Types::Struct
            Validation.Schema(parent: target, build: false) do
              other.schema.each { |attr, type| required(attr).filled(type) }
            end
          elsif other.respond_to?(:schema) && other.schema.is_a?(self)
            Class.new(other.schema.class)
          else
            Validation.Schema(target.schema_class, parent: target, build: false, &block)
          end

        klass.config.path = target.path if other
        klass.config.input_processor = :noop

        klass
      end

      def self.option(name, default = nil)
        attr_reader(*name)
        options.update(name => default)
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

      def self.options
        config.options
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

      def self.input_processor
        @input_processor ||=
          begin
            if input_processor_compiler
              input_processor_compiler.(rule_ast)
            else
              NOOP_INPUT_PROCESSOR
            end
          end
      end

      def self.input_processor_ast(type)
        config.input_processor_map.fetch(type).schema_ast(rule_ast)
      end

      def self.input_processor_compiler
        @input_processor_comp ||= config.input_processor_map[config.input_processor]
      end

      def self.rule_ast
        @rule_ast ||= config.rules.flat_map(&:rules).map(&:to_ast)
      end

      def self.default_options
        { predicates: predicates,
          error_compiler: error_compiler,
          hint_compiler: hint_compiler,
          input_processor: input_processor,
          checks: config.checks }
      end

      attr_reader :rules

      attr_reader :checks

      attr_reader :predicates

      attr_reader :input_processor

      attr_reader :rule_compiler

      attr_reader :error_compiler

      attr_reader :hint_compiler

      attr_reader :options

      def initialize(rules, options)
        @rule_compiler = SchemaCompiler.new(self)
        @error_compiler = options.fetch(:error_compiler)
        @hint_compiler = options.fetch(:hint_compiler)
        @predicates = options.fetch(:predicates)
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

      def [](name)
        if predicates.key?(name)
          predicates[name]
        elsif respond_to?(name)
          Logic::Predicate.new(name, &method(name))
        else
          raise ArgumentError, "+#{name}+ is not a valid predicate name"
        end
      end

      def curry(*args)
        to_proc.curry.(*args)
      end

      def to_proc
        -> input { self.call(input) }
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
