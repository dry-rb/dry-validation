module Dry
  module Validation
    class Rule
      class Value < Rule
        def call(input)
          Validation.Result(input, predicate.(input), self)
        end

        def type
          :val
        end
      end
    end
  end
end
