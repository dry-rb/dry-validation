module Dry
  module Validation
    class Rule
      include Dry::Equalizer(:name, :predicate)

      attr_reader :name, :predicate

      def initialize(name, predicate)
        @name = name
        @predicate = predicate
      end

      def type
        :rule
      end

      def call(*args)
        Validation.Result(args, predicate.call, self)
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

      def then(other)
        Implication.new(self, other)
      end
      alias_method :>, :then

      def curry(*args)
        self.class.new(name, predicate.curry(*args))
      end
    end
  end
end

require 'dry/validation/rule/key'
require 'dry/validation/rule/value'
require 'dry/validation/rule/each'
require 'dry/validation/rule/set'
require 'dry/validation/rule/composite'
require 'dry/validation/rule/group'
require 'dry/validation/rule/result'
