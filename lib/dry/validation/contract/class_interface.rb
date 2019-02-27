require 'dry/schema'
require 'dry/validation/messages'
require 'dry/validation/constants'

module Dry
  module Validation
    class Contract
      module ClassInterface
        def params(&block)
          @__schema__ ||= Schema.Params(parent: superclass&.schema, &block)
        end

        def json(&block)
          @__schema__ ||= Schema.JSON(parent: superclass&.schema, &block)
        end

        def rule(name, &block)
          rules << Rule.new(name: name, block: block)
          rules
        end

        def schema
          @__schema__ if defined?(@__schema__)
        end

        def rules
          @__rules__ ||= EMPTY_ARRAY.
            dup.
            concat(superclass.respond_to?(:rules) ? superclass.rules : EMPTY_ARRAY)
        end

        def messages
          @__messages__ ||= Messages.setup(config)
        end
      end
    end
  end
end
