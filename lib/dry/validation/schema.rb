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
      setting :error_compiler, ErrorCompiler.new(Validation.Messages())

      def self.predicates
        config.predicates
      end

      def self.error_compiler
        config.error_compiler
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
