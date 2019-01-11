require 'dry-schema'
require 'dry/validation/constants'

module Dry
  module Validation
    class Evaluator
      attr_reader :name

      attr_reader :params

      attr_reader :msg

      def initialize(name, params, &block)
        @name = name
        @params = params
        @failure = false
        instance_eval(&block)
      end

      def failure(msg)
        @msg = msg
        @failure = true
        self
      end

      def failure?
        @failure.equal?(true)
      end

      def to_error
        { name => [msg] }
      end
    end

    class Rule
      attr_reader :name, :paths, :block

      def initialize(paths, &block)
        @name = paths.first
        @paths = paths
        @block = block
      end

      def call(result)
        evaluator = Evaluator.new(name, result, &block)
        evaluator
      end
    end

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
          rule_result = rule.(result)
          h.update(rule_result.to_error) if rule_result.failure?
        end

        result.errors.merge(messages)
      end
    end
  end
end
