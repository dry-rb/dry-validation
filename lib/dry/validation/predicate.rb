require 'dry/validation/result'

module Dry
  module Validation
    class Predicate
      attr_reader :fn

      class Composite < Predicate
      end

      def initialize(&block)
        @fn = block
      end

      def call(*args)
        Validation.Result(fn.call(*args))
      end

      def &(other)
        Predicate::Composite.new { |*args| Validation.Result(fn.call(*args) && fn.call(*args)) }
      end

      def inversed
        self.class.new { |*args| Validation.Result(!fn.(*args)) }
      end

      def curry(*args)
        self.class.new(&fn.curry.(*args))
      end
    end
  end
end
