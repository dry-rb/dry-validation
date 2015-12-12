require 'dry/validation/schema/definition'
require 'dry/validation/predicates'
require 'dry/validation/error'
require 'dry/validation/rule_compiler'
require 'dry/validation/messages'
require 'dry/validation/error_compiler'
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

      def self.groups
        @__groups__ ||= []
      end

      attr_reader :rules, :groups

      attr_reader :error_compiler

      def initialize(error_compiler = self.class.error_compiler)
        compiler = RuleCompiler.new(self)
        @rules = compiler.(self.class.rules.map(&:to_ary))
        @groups = compiler.(self.class.groups.map(&:to_ary))
        @error_compiler = error_compiler
      end

      def call(input)
        validate_input(input)

        result = Validation::Result.new(rules.map { |rule| rule.(input) })

        groups.each do |group|
          result.with_values(group.rules) do |values|
            result << group.(*values)
          end
        end

        errors = Error::Set.new(result.failures.map { |failure| Error.new(failure) })

        Schema::Result.new(input, result, errors, error_compiler)
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

      private

      def validate_input(input)
        unless input.is_a?(Hash)
          raise ArgumentError, "expected a Hash but received +#{input.inspect}+"
        end
      end
    end
  end
end
