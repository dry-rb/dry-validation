module Dry
  module Validation
    class Rule::Check < Rule
      alias_method :result, :predicate

      def call(*)
        Validation.Result(nil, result.call, self)
      end

      def type
        :check
      end
    end
  end
end
