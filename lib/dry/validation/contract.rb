require 'dry-schema'
require 'dry/initializer'

require 'dry/validation/constants'
require 'dry/validation/rule'
require 'dry/validation/evaluator'

module Dry
  module Validation
    class Contract
      extend Dry::Initializer

      def self.params(&block)
        @__schema__ ||= Schema.Params(&block)
      end

      def self.schema
        @__schema__
      end

      def self.rule(name, &block)
        rules << Rule.new(name: name, block: block)
        rules
      end

      def self.rules
        @__rules__ ||= []
      end

      option :schema, default: -> { self.class.schema }

      option :rules, default: -> { self.class.rules }

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
