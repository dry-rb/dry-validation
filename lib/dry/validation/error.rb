module Dry
  module Validation
    class Error
      class Set
        include Enumerable

        attr_reader :errors

        def initialize
          @errors = []
        end

        def each(&block)
          errors.each(&block)
        end

        def empty?
          errors.empty?
        end

        def <<(error)
          errors << error
        end

        def to_ary
          errors.map { |error| error.to_ary }
        end
        alias_method :to_a, :to_ary
      end

      attr_reader :result, :rule

      def initialize(result, rule)
        @result = result
        @rule = rule
      end

      def to_ary
        [:error, [:rule, rule.name, [:result, result.to_ary]]]
      end
      alias_method :to_a, :to_ary
    end
  end
end
