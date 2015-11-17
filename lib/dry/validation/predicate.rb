module Dry
  module Validation
    def self.Predicate(block)
      case block
      when Method then Predicate.new(block.name, &block)
      else raise ArgumentError, 'predicate needs an :id'
      end
    end

    class Predicate
      include Dry::Equalizer(:id, :fn)

      attr_reader :id, :fn

      def initialize(id = nil, &block)
        @id = id
        @fn = block
      end

      def call(*args)
        fn.(*args)
      end

      def negation
        self.class.new(:"not_#{id}") { |*args| !fn.(*args) }
      end

      def curry(*args)
        self.class.new(id, &fn.curry.(*args))
      end
    end
  end
end
