require 'dry/logic/predicates'
require 'dry/logic/rule_compiler'

require 'dry/validation/schema/definition'
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
      extend Definition

      setting :predicates, Logic::Predicates
      setting :messages, :yaml
      setting :messages_file
      setting :namespace

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
        @checks = self.class.checks.map(&:to_ast)
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
