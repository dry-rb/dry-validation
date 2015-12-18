module Dry
  module Validation
    class Rule::Composite < Rule
      include Dry::Equalizer(:left, :right)

      attr_reader :name, :left, :right

      def initialize(left, right)
        @left = left
        @right = right
      end

      def name
        :"#{left.name}_#{type}_#{right.name}"
      end

      def to_ary
        [type, [left.to_ary, right.to_ary]]
      end
      alias_method :to_a, :to_ary
    end

    class Rule::Implication < Rule::Composite
      def call(*args)
        left.(*args) > right
      end

      def type
        :implication
      end
    end

    class Rule::Conjunction < Rule::Composite
      def call(*args)
        left.(*args).and(right)
      end

      def type
        :and
      end
    end

    class Rule::Disjunction < Rule::Composite
      def call(*args)
        left.(*args).or(right)
      end

      def type
        :or
      end
    end
  end
end
