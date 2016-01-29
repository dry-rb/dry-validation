require 'dry/logic/predicates'
require 'dry/logic/rule_compiler'

require 'dry/validation/schema/value'
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

      setting :predicates, Logic::Predicates
      setting :messages, :yaml
      setting :messages_file
      setting :namespace

      def self.key(name, &block)
        value = Value.new(name)
        key = value.key(name, &block)

        keys[name] = key

        key
      end

      def self.optional(name, &block)
        value = Value.new(name)
        key = value.optional(name, &block)

        keys[name] = key

        key
      end

      def self.attr(name, &block)
        value = Value.new(name)
        key = value.attr(name, &block)

        keys[name] = key

        key
      end

      def self.value(name)
        key = keys[name]

        if key
          keys[name].value(name)
        else
          Rule::Result.new(name, [], target: Value.new(name))
        end
      end

      def self.rule(identifier, &block)
        name, _ = Array(identifier).flatten
        key = keys[name]

        if key
          if block
            key.rule(identifier, &block)
          else
            rules.detect { |rule| rule.name == name }.to_success_check
          end
        else
          result = yield

          checks << Rule::Check.new(
            identifier, [:check, [name, result.to_ast, result.keys]],
            target: result.target
          )

          checks.last
        end
      end

      def self.keys
        @keys ||= {}
      end

      def self.rules
        keys.values.flat_map(&:rules)
      end

      def self.checks
        @checks ||= []
      end

      def self.check_ast
        (checks + keys.values.flat_map(&:checks)).map(&:to_ast)
      end

      def self.predicates
        config.predicates
      end

      def self.error_compiler
        ErrorCompiler.new(messages)
      end

      def self.hint_compiler
        HintCompiler.new(messages, rules: rules.map(&:to_ast))
      end

      def self.messages
        default =
          case config.messages
          when :yaml then Messages.default
          when :i18n then Messages::I18n.new
          else
            fail "+#{config.messages}+ is not a valid messages identifier"
          end

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

      attr_reader :rules, :checks

      attr_reader :rule_compiler

      attr_reader :error_compiler

      attr_reader :hint_compiler

      def initialize(rules = [])
        @rule_compiler = Logic::RuleCompiler.new(self)
        @rules = rule_compiler.(self.class.rules.map(&:to_ast) + rules.map(&:to_ast))
        @checks = self.class.check_ast
        @error_compiler = self.class.error_compiler
        @hint_compiler = self.class.hint_compiler
      end

      def call(input)
        result = Validation::Result.new(rules.map { |rule| rule.(input) })

        if checks.size > 0
          resolver = -> name { result[name] || self[name] }
          compiled_checks = Logic::RuleCompiler.new(resolver).(checks)

          compiled_checks.each do |rule|
            result << rule.(result)
          end
        end

        errors = Error::Set.new(result.failures.map { |failure| Error.new(failure) })

        Schema::Result.new(input, result, errors, error_compiler, hint_compiler)
      end

      def [](name)
        if predicates.key?(name)
          predicates[name]
        elsif respond_to?(name)
          Logic::Predicate.new(name, &method(name))
        else
          fail ArgumentError, "+#{name}+ is not a valid predicate name"
        end
      end

      def predicates
        self.class.predicates
      end
    end
  end
end
