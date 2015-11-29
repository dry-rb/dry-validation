require 'dry/validation/result'

module Dry
  module Validation
    class Rule
      include Dry::Equalizer(:name, :predicate)

      class Key < Rule
        def self.new(name, predicate)
          super(name, predicate.curry(name))
        end

        def type
          :key
        end

        def call(input)
          Validation.Result(input[name], predicate.(input), self)
        end
      end

      class Value < Rule
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

      class Composite
        include Dry::Equalizer(:left, :right)

        attr_reader :name, :left, :right

        def initialize(left, right)
          @name = left.name
          @left = left
          @right = right
        end

        def to_ary
          [type, [left.to_ary, right.to_ary]]
        end
        alias_method :to_a, :to_ary
      end

      class Conjunction < Composite
        def call(input)
          left.(input).and(right)
        end

        def type
          :and
        end
      end

      class Disjunction < Composite
        def call(input)
          left.(input).or(right)
        end

        def type
          :or
        end
      end

      class Each < Rule
        def call(input)
          Validation.Result(input, input.map { |element| predicate.(element) }, self)
        end

        def type
          :each
        end
      end

      class Set < Rule
        def call(input)
          Validation.Result(input, predicate.map { |rule| rule.(input) }, self)
        end

        def type
          :set
        end

        def at(*args)
          self.class.new(name, predicate.values_at(*args))
        end

        def to_ary
          [type, [name, predicate.map(&:to_ary)]]
        end
        alias_method :to_a, :to_ary
      end

      attr_reader :name, :predicate

      def initialize(name, predicate)
        @name = name
        @predicate = predicate
      end

      def to_ary
        [type, [name, predicate.to_ary]]
      end
      alias_method :to_a, :to_ary

      def and(other)
        Conjunction.new(self, other)
      end
      alias_method :&, :and

      def or(other)
        Disjunction.new(self, other)
      end
      alias_method :|, :or

      def curry(*args)
        self.class.new(name, predicate.curry(*args))
      end
    end
  end
end
