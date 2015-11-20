require 'dry/validation/predicate_set'

module Dry
  module Validation
    module Predicates
      module Methods
        def import(predicate_set)
          merge(predicate_set)
        end
      end

      extend Dry::Container::Mixin
      extend Methods
    end
  end
end
