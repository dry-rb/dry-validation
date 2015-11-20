require 'dry/validation/predicate_set'

module Dry
  module Validation
    module PredicateSet
      module BuiltIn
        extend PredicateSet

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
      end
    end
  end
end
