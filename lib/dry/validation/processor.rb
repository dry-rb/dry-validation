require 'dry/validation/attribute_extractor'
require 'dry/validation/rules'

module Dry
  module Validation
    module Processor
      extend ::Dry::Configurable

      module_function

      setting :attribute_extractor, ::Dry::Validation::AttributeExtractor
      setting :rules, ::Dry::Validation::Rules

      def call(rules_hash, subject)
        Hash[rules_hash].each_with_object({}) do |(attribute, rule_set), result|
          errors = rule_set.flat_map do |rule_name, options|
            rules[rule_name].call(
              attribute_extractor.call(subject, attribute),
              options,
              self
            )
          end.compact

          result[attribute] = errors unless errors.empty?
        end
      end

      # @api private
      def attribute_extractor
        config.attribute_extractor
      end

      # @api private
      def rules
        config.rules
      end
    end
  end
end
