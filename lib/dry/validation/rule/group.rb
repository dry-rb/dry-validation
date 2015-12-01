module Dry
  module Validation
    class Rule::Group < Rule
      alias_method :rules, :name

      def call(*input)
        Validation.Result(input, predicate.(*input), self)
      end

      def type
        :group
      end
    end
  end
end
