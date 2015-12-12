module Dry
  module Validation
    class Result
      include Enumerable

      attr_reader :rule_results

      def initialize(rule_results)
        @rule_results = rule_results
      end

      def each(&block)
        rule_results.each(&block)
      end

      def to_ary
        failures.map(&:to_ary)
      end

      def <<(rule_result)
        rule_results << rule_result
      end

      def with_values(names, &_block)
        values = names.map { |name| by_name(name) }.compact.map(&:input)
        yield(values) if values.size == names.size
      end

      def by_name(name)
        successes.detect { |rule_result| rule_result.name == name }
      end

      def successes
        rule_results.select(&:success?)
      end

      def failures
        rule_results.select(&:failure?)
      end
    end
  end
end
