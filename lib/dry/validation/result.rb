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

      def [](name)
        to_h[name]
      end

      def to_h
        @to_h ||= each_with_object({}) { |result, hash| hash[result.name] = result }
      end

      def merge!(other)
        rule_results.concat(other.rule_results)
      end

      def to_ary
        failures.map(&:to_ary)
      end

      def <<(rule_result)
        rule_results << rule_result
      end

      def with_values(names, &block)
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
