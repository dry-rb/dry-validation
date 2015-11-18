require 'dry/validation/predicate'

module Dry
  module Validation
    module Predicates
      module Methods
        def predicate(name, &block)
          register(name, Predicate.new(name, &block))
        end
      end

      extend Dry::Container::Mixin
      extend Methods

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
        ! self[:empty?].(input)
      end

      predicate(:int?) do |input|
        input.is_a?(Fixnum)
      end

      predicate(:str?) do |input|
        input.is_a?(String)
      end

      predicate(:gt?) do |num, input|
        input > num
      end

      predicate(:min_size?) do |num, input|
        input.size >= num
      end
    end
  end
end
