module Dry
  module Validation
    def self.Predicate(block)
      case block
      when Method
        Predicate.new(block.name, &block)
      else
        fail ArgumentError, 'predicate needs an :id'
      end
    end

    class Predicate
      include Dry::Equalizer(:id)

      attr_reader :id, :args, :fn

      def initialize(id, *args, &block)
        @id = id
        @fn = block
        @args = args
      end

      def call(*args)
        fn.(*args)
      end

      def negation
        self.class.new(:"not_#{id}") { |input| !fn.(input) }
      end

      def curry(*args)
        self.class.new(id, *args, &fn.curry.(*args))
      end

      def to_ary
        [:predicate, [id, args]]
      end
      alias_method :to_a, :to_ary
    end
  end
end
