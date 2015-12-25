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

      class << self
        def predicates
          config.predicates
        end

        def error_compiler
          ErrorCompiler.new(messages)
        end

        def messages
          if config.messages_file && config.namespace
            default_messages.merge(config.messages_file).namespaced(config.namespace)
          elsif config.messages_file
            default_messages.merge(config.messages_file)
          elsif config.namespace
            default_messages.namespaced(config.namespace)
          else
            default_messages
          end
        end

        def rules
          @__rules__ ||= []
        end

        def groups
          @__groups__ ||= []
        end

        private

        def default_messages
          case config.messages
          when :yaml
            Messages.default
          when :i18n
            Messages::I18n.new
          else
            fail "+#{config.messages}+ is not a valid messages identifier"
          end
        end
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
        result = validation_result_for(input)
        errors = Error::Set.new(result.failures.map { |failure| Error.new(failure) })

        Schema::Result.new(input, result, errors, error_compiler)
      end

      def [](name)
        if predicates.key?(name)
          predicates[name]
        elsif respond_to?(name)
          Predicate.new(name, &method(name))
        else
          fail ArgumentError, "+#{name}+ is not a valid predicate name"
        end
      end

      def predicates
        self.class.predicates
      end

      private

      def validation_result_for(input)
        Validation::Result.new(rules.map { |rule| rule.(input) }).tap do |result|
          groups.each do |group|
            result.with_values(group.rules) do |values|
              result << group.(*values)
            end
          end
        end
      end
    end
  end
end
