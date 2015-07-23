require 'dry/validator/attribute_extractor'
require 'dry/validator/rules'

module Dry
  class Validator
    # (Default) processor for validations
    #
    # @example
    #
    #   validator = Dry::Validator.new(name: { presence: true })
    #   Dry::Validator::Processor.call(validator, name: '')
    #     # => {:name=>[{:code=>"presence", :options=>true}]}
    #
    # @api public
    module Processor
      extend ::Dry::Configurable

      module_function

      setting :attribute_extractor, ::Dry::Validator::AttributeExtractor
      setting :rules, ::Dry::Validator::Rules
      # Validate subject using validator
      #
      # @param [Mixed] validator The (callable) validator
      # @param [Mixed] subject The validation subject
      #
      # @return Dry::Validator
      #
      # @api public
      def call(validator, subject)
        validator.rules.each_with_object({}) do |(attribute, rule_set), result|
          errors = rule_set.flat_map do |rule_name, options|
            rules[rule_name].call(
              attribute_extractor.call(subject, attribute),
              options,
              validator
            )
          end.compact

          result[attribute] = errors unless errors.all?(&:empty?)
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
