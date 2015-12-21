module Dry
  module Validation
    def self.Result(input, value, rule)
      case value
      when Rule::Result then value.class.new(value.input, value.success?, rule)
      when Array then Rule::Result::Set.new(input, value, rule)
      else Rule::Result::Value.new(input, value, rule)
      end
    end

    class Rule::Result
      include Dry::Equalizer(:success?, :input, :rule)

      attr_reader :input, :value, :rule, :name

      class Rule::Result::Set < Rule::Result
        def success?
          value.all?(&:success?)
        end

        def to_ary
          indices = value.map { |v| v.failure? ? value.index(v) : nil }.compact
          [:input, [rule.name, input, value.values_at(*indices).map(&:to_ary)]]
        end
      end

      class Rule::Result::Value < Rule::Result
        def to_ary
          [:input, [rule.name, input, [rule.to_ary]]]
        end
        alias_method :to_a, :to_ary
      end

      class Rule::Result::Verified < Rule::Result
        attr_reader :predicate_id

        def initialize(result, predicate_id)
          @input = result.input
          @value = result.value
          @rule = result.rule
          @name = result.name
          @predicate_id = predicate_id
        end

        def call
          Validation.Result(input, success?, rule)
        end

        def to_ary
          [:input, [name, input, [rule.to_ary]]]
        end
        alias_method :to_a, :to_ary

        def success?
          rule.predicate_id == predicate_id
        end
      end

      def initialize(input, value, rule)
        @input = input
        @value = value
        @rule = rule
        @name = rule.name
      end

      def call
        self
      end

      def curry(predicate_id = nil)
        if predicate_id
          Rule::Result::Verified.new(self, predicate_id)
        else
          self
        end
      end

      def negated
        self.class.new(input, !value, rule)
      end

      def >(other)
        if success?
          other.(input)
        else
          Validation.Result(input, true, rule)
        end
      end

      def and(other)
        if success?
          other.(input)
        else
          self
        end
      end

      def or(other)
        if success?
          self
        else
          other.(input)
        end
      end

      def xor(other)
        Validation.Result(input, success? ^ other.(input).success?, rule)
      end

      def success?
        @value
      end

      def failure?
        ! success?
      end
    end
  end
end
