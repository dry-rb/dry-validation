require 'dry/validation/schema/definition'
require 'dry/validation/predicates'
require 'dry/validation/error'
require 'dry/validation/rule_compiler'
require 'dry/validation/messages'
require 'dry/validation/error_compiler'

module Dry
  module Validation
    class Schema
      extend Dry::Configurable
      extend Definition

      setting :predicates, Predicates
      setting :messages, Messages.default
      setting :messages_file
      setting :namespace

      def self.predicates
        config.predicates
      end

      def self.error_compiler
        ErrorCompiler.new(messages)
      end

      def self.messages
        default = config.messages

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

      attr_reader :rules

      attr_reader :error_compiler

      def initialize(error_compiler = self.class.error_compiler)
        @rules = RuleCompiler.new(self).(self.class.rules.map(&:to_ary))
        @error_compiler = error_compiler
      end

      def call(input)
        rules.each_with_object(Error::Set.new) do |rule, errors|
          result = rule.(input)
          errors << Error.new(result) if result.failure?
        end
      end

      def messages(input)
        error_compiler.call(call(input).map(&:to_ary))
      end

      def [](name)
        if methods.include?(name)
          Predicate.new(name, &method(name))
        else
          self.class.predicates[name]
        end
      end
    end
  end
end
