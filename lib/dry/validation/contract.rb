require 'dry-schema'
require 'dry/initializer'

require 'dry/validation/constants'
require 'dry/validation/rule'
require 'dry/validation/evaluator'
require 'dry/validation/result'

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
        Result.new(schema.(input)) do |result|
          rules.each do |rule|
            next if result.error?(rule.name)
            rule_result = rule.(self, result)
            result.add_error(rule.name, rule_result.message) if rule_result.failure?
          end
        end
      end
    end
  end
end
