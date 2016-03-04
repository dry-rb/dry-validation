require 'dry/logic/predicates'
require 'dry/logic/rule_compiler'

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

      setting :predicates, Logic::Predicates
      setting :messages, :yaml
      setting :messages_file
      setting :namespace

      def self.key(name, &block)
        keys[name] = Value[name].key(name, &block)
      end

      def self.optional(name, &block)
        keys[name] = Value[name].optional(name, &block)
      end

      def self.rule(name, &block)
        val = Value[name].instance_exec(&block)
        keys[name] = Value.new(rules: [val])
      end

      def self.keys
        @keys ||= {}
      end

      def self.rules
        keys.values.flat_map(&:rules)
      end

      def self.rule_ast
        rules.map(&:to_ast)
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

      attr_reader :rules

      attr_reader :rule_compiler

      attr_reader :error_compiler

      attr_reader :hint_compiler

      def initialize(rules = [])
        @rule_compiler = Logic::RuleCompiler.new(self)
        @rules = rule_compiler.(rules + self.class.rule_ast)
        @error_compiler = self.class.error_compiler
        @hint_compiler = self.class.hint_compiler
      end

      def call(input)
        result = Validation::Result.new(rules.map { |rule| rule.(input) })
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
