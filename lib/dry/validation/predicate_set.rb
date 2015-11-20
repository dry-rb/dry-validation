require 'dry/validation/predicate'

module Dry
  module Validation
    module PredicateSet
      module Methods
        def predicate(name, &block)
          register(name) { Predicate.new(name, &block) }
        end

        def import(predicate_set)
          merge(predicate_set)
        end
      end

      def self.extended(other)
        super
        other.extend(Methods, Dry::Container::Mixin)
      end
    end
  end
end
