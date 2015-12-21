require 'dry/validation/schema/definition'
require 'dry/validation/predicates'
require 'dry/validation/error'
require 'dry/validation/rule_compiler'
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

      setting :predicates, Predicates
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
        HintCompiler.new(messages, rules: rules.map(&:to_ary))
      end

      def self.messages
        default =
          case config.messages
          when :yaml then Messages.default
          when :i18n then Messages::I18n.new
          else
            raise RuntimeError, "+#{config.messages}+ is not a valid messages identifier"
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

      def self.rules
        @__rules__ ||= []
      end

      def self.schemas
        @__schemas__ ||= []
      end

      def self.groups
        @__groups__ ||= []
      end

      def self.checks
        @__checks__ ||= []
      end

      attr_reader :rules, :schemas, :groups, :checks

      attr_reader :error_compiler

      attr_reader :hint_compiler

      def initialize(error_compiler = self.class.error_compiler, hint_compiler = self.class.hint_compiler)
        compiler = RuleCompiler.new(self)
        @rules = compiler.(self.class.rules.map(&:to_ary))
        @checks = self.class.checks
        @groups = compiler.(self.class.groups.map(&:to_ary))
        @schemas = self.class.schemas.map(&:new)
        @error_compiler = error_compiler
        @hint_compiler = hint_compiler
      end

      def call(input)
        result = Validation::Result.new(rules.map { |rule| rule.(input) })

        schemas.each do |schema|
          result.merge!(schema.(input).result)
        end

        if checks.size > 0
          compiled_checks = RuleCompiler.new(result.to_h).(checks)

          compiled_checks.each do |rule|
            result << rule.()
          end
        end

        groups.each do |group|
          result.with_values(group.rules) do |values|
            result << group.(*values)
          end
        end

        errors = Error::Set.new(result.failures.map { |failure| Error.new(failure) })

        Schema::Result.new(input, result, errors, error_compiler, hint_compiler)
      end

      def [](name)
        if predicates.key?(name)
          predicates[name]
        elsif respond_to?(name)
          Predicate.new(name, &method(name))
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
