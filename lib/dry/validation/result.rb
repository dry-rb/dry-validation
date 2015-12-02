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

      def successes
        rule_results.select(&:success?)
      end

      def failures
        rule_results.select(&:failure?)
      end
    end
  end
end
