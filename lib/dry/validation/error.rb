module Dry
  module Validation
    class Error
      class Set
        include Enumerable

        attr_reader :errors

        def initialize(errors)
          @errors = errors
        end

        def each(&block)
          errors.each(&block)
        end

        def empty?
          errors.empty?
        end

        def to_ary
          errors.map { |error| error.to_ary }
        end
        alias_method :to_a, :to_ary
      end

      attr_reader :result

      def initialize(result)
        @result = result
      end

      def to_ary
        [:error, result.to_ary]
      end
      alias_method :to_a, :to_ary
    end
  end
end
