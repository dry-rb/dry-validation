module Dry
  module Validation
    class Rule
      class Composite < Rule
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

      class Implication < Composite
        def call(input)
          left.(input) > right
        end

        def type
          :implication
        end
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
    end
  end
end
