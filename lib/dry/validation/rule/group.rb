module Dry
  module Validation
    class Rule::Group < Rule
      alias_method :rules, :name

      def call(result)
        values = rules
          .map { |name| result.detect { |r| r.rule.name == name } }
          .select(&:success?)
          .map(&:input)

        if values.size == rules.size
          Validation.Result(values, predicate.(*values), self)
        else
          Validation.Result(result.map(&:input), false, self)
        end
      end
    end
  end
end
