require 'dry/validation/result'

module Dry
  module Validation
    class Rule
      include Dry::Equalizer(:name, :predicate)

      class Composite
        include Dry::Equalizer(:left, :right)

        attr_reader :name, :left, :right

        def initialize(left, right)
          @name = left.name
          @left = left
          @right = right
        end

        def call(input)
          result = left.(input)

          if result.success?
            right.(result.input)
          else
            result
          end
        end

        def to_ary
          [left.to_ary, [right.to_ary]]
        end
        alias_method :to_a, :to_ary
      end

      class Key < Rule
        def self.new(name, predicate)
          super(name, predicate.curry(name))
        end

        def call(input)
          Validation.Result(input[name], predicate.(input), predicate.id)
        end
      end

      class Value < Rule
        def call(input)
          Validation.Result(input, predicate.(input), predicate.id)
        end
      end

      attr_reader :name, :predicate

      def initialize(name, predicate)
        @name = name
        @predicate = predicate
      end

      def curry(*args)
        self.class.new(name, predicate.curry(*args))
      end

      def compose(other)
        Composite.new(self, other)
      end
      alias_method :>>, :compose
    end
  end
end
