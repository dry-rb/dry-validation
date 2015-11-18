module Dry
  module Validation
    def self.Result(input, value, predicate = nil)
      case value
      when Array then Result::Set.new(input, value)
      else Result::Value.new(input, value, predicate)
      end
    end

    class Result
      attr_reader :input, :value, :predicate

      class Set < Result
        def success?
          value.all?(&:success?)
        end
      end

      class Value < Result
        attr_reader :predicate

        def initialize(input, value, predicate)
          super(input, value)
          @predicate = predicate
        end

        def to_ary
          [:input, input, [:predicate, *predicate.to_ary]]
        end
        alias_method :to_a, :to_ary
      end

      def initialize(input, value)
        @input = input
        @value = value
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

      def success?
        @value
      end

      def failure?
        ! success?
      end
    end
  end
end
