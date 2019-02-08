require 'dry/validation/constants'

module Dry
  module Validation
    class Contract
      module ClassInterface
        def params(&block)
          @__schema__ ||= Schema.Params(parent: superclass&.schema, &block)
        end

        def rule(name, &block)
          rules << Rule.new(name: name, block: block)
          rules
        end

        def schema
          if defined?(@__schema__)
            instance_variable_get('@__schema__')
          end
        end

        def rules
          if defined?(@__rules__)
            @__rules__
          else
            @__rules__ = EMPTY_ARRAY.
              dup.
              concat(superclass.respond_to?(:rules) ? superclass.rules : EMPTY_ARRAY)
          end
        end
      end
    end
  end
end
