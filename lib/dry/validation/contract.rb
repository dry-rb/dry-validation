require 'dry-schema'
require 'dry/initializer'

require 'dry/validation/constants'
require 'dry/validation/rule'
require 'dry/validation/evaluator'
require 'dry/validation/result'
require 'dry/validation/contract/class_interface'

module Dry
  module Validation
    class Contract
      extend Dry::Initializer
      extend ClassInterface

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
