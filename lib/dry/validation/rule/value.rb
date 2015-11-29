module Dry
  module Validation
    class Rule::Value < Rule
      def self.new(name, predicate)
        if predicate.id == :none?
          super(name, predicate)
        else
          Optional.new(name, predicate)
        end
      end

      class Optional < Rule
        def call(input)
          value = input.respond_to?(:value) ? input.value : input
          Validation.Result(value, predicate.(value), self)
        end

        def type
          :val
        end
      end

      def call(input)
        Validation.Result(input, predicate.(input), self)
      end

      def type
        :val
      end
    end
  end
end
