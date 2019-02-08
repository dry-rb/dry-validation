module Dry
  module Validation
    class Contract
      module ClassInterface
        def params(&block)
          @__schema__ ||= Schema.Params(&block)
        end

        def schema
          @__schema__
        end

        def rule(name, &block)
          rules << Rule.new(name: name, block: block)
          rules
        end

        def rules
          @__rules__ ||= []
        end
      end
    end
  end
end
