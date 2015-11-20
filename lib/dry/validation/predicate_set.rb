require 'dry/validation/predicate'
require 'dry/validation/predicates'

module Dry
  module Validation
    module PredicateSet
      module Methods
        def predicate(name, &block)
          register(name) { Predicate.new(name, &block) }
        end
      end

      def self.extended(base)
        base.extend(Dry::Container::Mixin, Methods)
      end
    end
  end
end
