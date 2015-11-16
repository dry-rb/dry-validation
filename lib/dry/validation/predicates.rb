require 'dry/validation/predicate'

module Dry
  module Validation
    class Predicates
      extend Dry::Container::Mixin

      def self.value?(name, input)
        input.key?(name)
      end
      register(:value?, Validation.Predicate(method(:value?)))

      def self.empty?(input)
        case input
        when String, Array, Hash then input.empty?
        when nil then true
        else
          false
        end
      end
      register(:empty?, Validation.Predicate(method(:empty?)))
      register(:filled?, self[:empty?].negation)

      def self.present?(name, input)
        self[:value?].(name, input) && self[:filled?].(input[name])
      end
      register(:present?, Validation.Predicate(method(:present?)))

      def self.int?(input)
        input.is_a?(Fixnum)
      end
      register(:int?, Validation.Predicate(method(:int?)))

      def self.gt?(num, input)
        input > num
      end
      register(:gt?, Validation.Predicate(method(:gt?)))
    end
  end
end
