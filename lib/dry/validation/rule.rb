require 'dry/validation/result'

module Dry
  module Validation
    class Rule
      include Dry::Equalizer(:name, :predicate)

      class Composite
        include Dry::Equalizer(:left, :right)

        attr_reader :left, :right

        def initialize(left, right)
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
      end

      class Key < Rule
        def self.new(name, predicate)
          super(name, predicate.curry(name))
        end

        def call(input)
          Validation.Result(input[name], predicate.(input))
        end
      end

      attr_reader :name, :predicate

      def initialize(name, predicate)
        @name = name
        @predicate = predicate
      end

      def call(input)
        Validation.Result(input, predicate.(input))
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
