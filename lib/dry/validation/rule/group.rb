module Dry
  module Validation
    class Rule
      class Group < Rule
        attr_reader :rules

        def initialize(identifier, predicate)
          name, rules = identifier.to_a.first
          @rules = rules
          super(name, predicate)
        end

        def call(*input)
          Validation.Result(input, predicate.(*input), self)
        end

        def type
          :group
        end
      end
    end
  end
end
