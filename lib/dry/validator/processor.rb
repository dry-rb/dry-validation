require 'dry/validator/processor/attribute_extractor'
require 'dry/rules'

module Dry
  class Validator
    module Processor
      extend ::Dry::Configurable

      module_function

      setting :attribute_extractor, AttributeExtractor
      setting :rules, ::Dry::Rules

      def call(validator, object)
        validator.rules.each_with_object({}) do |(attribute, rule_set), result|
          errors = rule_set.flat_map do |rule_name, options|
            rules[rule_name].call(
              attribute_extractor.call(object, attribute),
              options,
              validator
            )
          end.compact

          result[attribute] = errors unless errors.all?(&:empty?)
        end
      end

      def attribute_extractor
        config.attribute_extractor
      end

      def rules
        config.rules
      end
    end
  end
end
