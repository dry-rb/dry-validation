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

      def success?
        failures.empty?
      end

      def [](name)
        rule_results[name]
      end

      def merge!(other_results)
        rule_results.merge!(other_results)
      end

      def to_ary
        failures.map(&:to_ary)
      end

      def successes
        rule_results.select { |_, value| value.success? }
      end

      def failures
        rule_results.select { |_, value| value.failure? }
      end
    end
  end
end
