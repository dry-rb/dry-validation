module Dry
  module Validation
    class Rule::Value < Rule
      def call(input)
        Validation.Result(input, predicate.(input), self)
      end

      def type
        :val
      end
    end
  end
end
