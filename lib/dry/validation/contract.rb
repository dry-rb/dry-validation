require 'dry-schema'
require 'dry/validation/constants'
require 'dry/validation/rule'
require 'dry/validation/evaluator'

module Dry
  module Validation
    class Contract
      def self.params(&block)
        @__schema__ ||= Schema.Params(&block)
      end

      def self.schema
        @__schema__
      end

      def self.rule(*paths, &block)
        rules << Rule.new(paths, &block)
        rules
      end

      def self.rules
        @__rules__ ||= []
      end

      attr_reader :schema

      attr_reader :rules

      def initialize(rules: self.class.rules, schema: self.class.schema)
        @rules = rules
        @schema = schema
      end

      def call(input)
        result = schema.(input)

        messages = rules.each_with_object({}) do |rule, h|
          next if result.error?(rule.name)
          rule_result = rule.(self, result)
          h.update(rule_result.to_error) if rule_result.failure?
        end

        result.errors.merge(messages)
      end
    end
  end
end
