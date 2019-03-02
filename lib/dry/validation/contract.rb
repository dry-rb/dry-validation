require 'dry/configurable'
require 'dry/initializer'

require 'dry/validation/constants'
require 'dry/validation/rule'
require 'dry/validation/evaluator'
require 'dry/validation/result'
require 'dry/validation/contract/class_interface'

module Dry
  module Validation
    class Contract
      extend Dry::Configurable
      extend Dry::Initializer
      extend ClassInterface

      setting :messages, :yaml
      setting :messages_file
      setting :namespace

      option :schema, default: -> { self.class.__schema__ }

      option :rules, default: -> { self.class.rules }

      option :messages, default: -> { self.class.messages }

      def call(input)
        Result.new(schema.(input)) do |result|
          rules.each do |rule|
            next if result.error?(rule.name)

            rule_result = rule.(self, result)
            result.add_error(rule.name, rule_result.message) if rule_result.failure?
          end
        end
      end

      def message(key, tokens: EMPTY_HASH, **opts)
        template = messages[key, opts.merge(tokens)]

        if template
          template.(template.data(tokens))
        else
          raise MissingMessageError, "Message template for #{key.inspect} was not found"
        end
      end
    end
  end
end
