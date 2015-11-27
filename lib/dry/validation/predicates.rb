require 'dry/validation/predicate_set'

module Dry
  module Validation
    module Predicates
      extend PredicateSet

      def self.included(other)
        super
        other.extend(PredicateSet)
        other.import(self)
      end

      predicate(:nil?) do |input|
        input.nil?
      end

      predicate(:key?) do |name, input|
        input.key?(name)
      end

      predicate(:empty?) do |input|
        case input
        when String, Array, Hash then input.empty?
        when nil then true
        else
          false
        end
      end

      predicate(:filled?) do |input|
        !self[:empty?].(input)
      end

      predicate(:int?) do |input|
        input.is_a?(Fixnum)
      end

      predicate(:str?) do |input|
        input.is_a?(String)
      end

      predicate(:hash?) do |input|
        input.is_a?(Hash)
      end

      predicate(:array?) do |input|
        input.is_a?(Array)
      end

      predicate(:lt?) do |num, input|
        input < num
      end

      predicate(:gt?) do |num, input|
        input > num
      end

      predicate(:lteq?) do |num, input|
        !self[:gt?].(num, input)
      end

      predicate(:gteq?) do |num, input|
        !self[:lt?].(num, input)
      end

      predicate(:size?) do |num, input|
        input.size == num
      end

      predicate(:min_size?) do |num, input|
        input.size >= num
      end

      predicate(:max_size?) do |num, input|
        input.size <= num
      end

      predicate(:inclusion?) do |list, input|
        list.include?(input)
      end

      predicate(:exclusion?) do |list, input|
        !self[:inclusion?].(list, input)
      end

      predicate(:eql?) do |left, right|
        left.eql?(right)
      end

      predicate(:format?) do |regex, input|
        !regex.match(input).nil?
      end
    end
  end
end
